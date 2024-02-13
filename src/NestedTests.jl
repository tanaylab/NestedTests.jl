"""
Run tests in nested environments.
"""
module NestedTests

export nested_test
export test_name
export test_prefixes
export abort_on_first_failure

using Printf
using Test

ABORT_ON_FIRST_FAILURE::Bool = false

"""
    abort_on_first_failure(abort::Bool)::Bool

Specify whether to abort the execution when encountering a test failure (by default, `false`). Returns the previous
setting.
"""
function abort_on_first_failure(abort::Bool)::Bool
    global ABORT_ON_FIRST_FAILURE
    previous = ABORT_ON_FIRST_FAILURE
    return ABORT_ON_FIRST_FAILURE = abort
end

run_prefixes = Vector{Vector{SubString{String}}}()
full_name = ""
test_names = String[]
this_test = Int[]
next_test = Int[]
depth = 0
cases = 0
errors = 0
start_time_ns = UInt64(0)

struct DoneNestedTestException <: Exception end

"""
    test_prefixes(prefixes::Vector{Union{String}})::Nothing

Specify prefixes for the tests to run. Only tests whose [`test_name`](@ref) matches any of these prefixes will be run.
If the vector is empty (the default), all the tests will be run.
"""
function test_prefixes(prefixes::Vector{String})::Nothing
    global run_prefixes
    run_prefixes = [split(prefix, "/") for prefix in prefixes]
    return nothing
end

"""
    test_name()::String

Return the full name of the current test, with `/` separating the nested test names.
"""
function test_name()::String
    global full_name
    return full_name
end

function matches_prefix(test_names::Vector{String}, prefix_names::Vector{SubString{String}})::Bool
    for (test_name, prefix_name) in zip(test_names, prefix_names)
        if test_name != prefix_name
            return false
        end
    end
    return true
end

function matches_prefixes(test_names::Vector{String})::Bool
    global run_prefixes
    if isempty(run_prefixes)
        return true
    end
    for prefix in run_prefixes
        if matches_prefix(test_names, prefix)
            return true
        end
    end
    return false
end

"""
    nested_test(name::String) do ... end

Run tests in a nested environment. The test can use any of the variables defined in its parent test(s). Any changes made
to these variables will be isolated from other sibling nested tests in this level, but will be visible to descendant
nested tests.
"""
function nested_test(code::Function, name::AbstractString)::Nothing
    if depth == 0
        top_nested_test(code, name)
    else
        deep_nested_test(code, name)
    end
    return nothing
end

function top_nested_test(code::Function, name::AbstractString)::Nothing
    global full_name
    global test_names
    global this_test
    global next_test
    global depth
    global cases
    global errors

    @assert full_name == ""
    @assert isempty(test_names)
    @assert isempty(next_test)
    @assert isempty(this_test)
    @assert depth == 0
    @assert cases == 0
    @assert errors == 0

    if !matches_prefixes([name])
        return nothing
    end

    try
        start_time_ns = time_ns()
        push!(this_test, 0)
        push!(next_test, 1)
        depth = 1

        while next_test[1] < 2 && (!ABORT_ON_FIRST_FAILURE || errors == 0)
            @debug "Look for next test..."
            this_test[1] = 0
            try
                deep_nested_test(code, name)
            catch exception
                if !(exception isa DoneNestedTestException)
                    rethrow(exception)  # untested
                end
                cases += 1
            end
            @assert length(this_test) == 1
        end

        @assert isempty(test_names)
        if errors > 0
            throw(Test.FallbackTestSetException("$(name)/... : $(errors) failed out of $(cases) test cases"))
        end

        elapsed_time_s = (time_ns() - start_time_ns) / 1e9
        printstyled(
            "$(name)/... : all $(cases) test cases passed in $(@sprintf("%.2f", elapsed_time_s)) seconds\n";
            color = :green,
        )
        return nothing

    finally
        full_name = ""
        empty!(test_names)
        empty!(next_test)
        empty!(this_test)
        depth = 0
        cases = 0
        errors = 0
    end
end

function deep_nested_test(code::Function, name::AbstractString)::Nothing
    global full_name
    global test_names
    global this_test
    global next_test
    global depth
    global errors

    @assert length(this_test) == depth
    this_test[depth] += 1

    if length(next_test) < depth
        push!(next_test, 1)
    end
    @assert length(next_test) >= depth

    push!(test_names, name)
    full_name = join(test_names, "/")

    if this_test < next_test[1:depth]
        @debug "Skip $(full_name)..."
        pop!(test_names)
        return nothing
    end

    if length(next_test) == depth
        next_test = copy(next_test)
        @info "Test $(full_name)..."
    end

    depth += 1
    push!(this_test, 0)

    is_done = false
    try
        if matches_prefixes(test_names)
            code()
        else
            @debug "Filter $(full_name)..."
        end
        is_done = true
    catch exception
        if exception isa Test.FallbackTestSetException
            is_done = true
            global errors
            errors += 1
        else
            rethrow(exception)
        end
    finally
        full_name = "fnord"
        pop!(test_names)
        pop!(this_test)
        depth -= 1

        if is_done
            if length(this_test) < length(next_test)
                pop!(next_test)
            end
            if length(this_test) == length(next_test)
                next_test[end] += 1
            end
        end
    end

    throw(DoneNestedTestException())
end

end # module
