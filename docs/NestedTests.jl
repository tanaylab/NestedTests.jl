"""
Run tests in nested environments.
"""
module NestedTests

export @nested_test
export test_name
export test_prefixes

using Test

run_prefixes = Vector{Vector{SubString{String}}}()
test_names = String[]
this_test = Int[]
next_test = Int[]
depth = 0
errors = 0
full_name = ""

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
    @nested_test(name::String) do ... end

Run tests in a nested environment. The test can use any of the variables defined in its parent test(s). Any changes made
to these variables will be isolated from other sibling nested tests in this level, but will be visible to descendant
nested tests.
"""
macro nested_test(code, name)
    return quote
        if NestedTests.run_nested_test($code, $name)
            return :restart
        end
    end
end

"""
    test_name()::String

Return the full name of the current test, with `/` separating the nested test names.
"""
function test_name()::String
    global full_name
    return full_name
end

function matches_prefix(prefix_names::Vector{SubString{String}})::Bool
    global test_names
    for (test_name, prefix_name) in zip(test_names, prefix_names)
        if test_name != prefix_name
            return false
        end
    end
    return true
end

function matches_prefixes()::Bool
    global run_prefixes
    if isempty(run_prefixes)
        return true
    end
    for prefix in run_prefixes
        if matches_prefix(prefix)
            return true
        end
    end
    return false
end

function run_nested_test(code::Function, name::AbstractString)::Bool
    global this_test
    global next_test
    global depth
    global errors

    if depth == 0
        @assert isempty(test_names)
        @assert isempty(next_test)
        @assert isempty(this_test)
        @assert errors == 0

        push!(this_test, 0)
        push!(next_test, 1)
        depth = 1

        while next_test[1] < 2
            this_test[1] = 0
            run_nested_test(code, name)
            @assert length(this_test) == 1
        end

        caught_errors = errors

        @assert isempty(test_names)
        empty!(next_test)
        empty!(this_test)
        depth = 0
        errors = 0

        if caught_errors > 0
            throw(Test.FallbackTestSetException("Tests failed with $(caught_errors) error(s)"))
        end
        return false
    end

    @assert length(this_test) == depth
    this_test[depth] += 1

    if length(next_test) < depth
        push!(next_test, 1)
    end
    @assert length(next_test) >= depth

    if this_test < next_test[1:depth]
        return false
    end

    push!(test_names, name)
    global full_name
    full_name = join(test_names, "/")

    if length(next_test) == depth
        next_test = copy(next_test)
        @info "Test $(full_name)..."
    end

    depth += 1
    push!(this_test, 0)
    is_done = true

    try
        if matches_prefixes()
            is_done = code() != :restart
        end
    catch exception
        if exception isa Test.FallbackTestSetException
            global errors
            errors += 1
        else
            rethrow(exception)
        end
    finally
        depth -= 1
        pop!(this_test)

        if is_done
            if length(this_test) < length(next_test)
                pop!(next_test)
            end
            if length(this_test) == length(next_test)
                next_test[end] += 1
            end
        end

        pop!(test_names)
    end

    return true
end

end # module
