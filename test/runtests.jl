using Test

using NestedTests

lines = String[]

function all_tests()::Nothing
    nested_test("top") do
        top_v = 1
        push!(lines, "---")
        push!(lines, "$(test_name()) top_v: $(top_v)")

        nested_test("mid_1") do
            mid_v = 1

            push!(lines, "$(test_name()) top_v: $(top_v)")
            push!(lines, "$(test_name()) mid_v: $(mid_v)")

            @test true == false

            @assert false  # untested
        end

        nested_test("mid_2") do
            mid_v = 1
            push!(lines, "$(test_name()) top_v: $(top_v)")
            push!(lines, "$(test_name()) mid_v: $(mid_v)")

            for deep in 1:2
                nested_test("deep_$(deep)") do
                    deep_v = 1

                    push!(lines, "$(test_name()) top_v: $(top_v)")
                    push!(lines, "$(test_name()) mid_v: $(mid_v)")
                    push!(lines, "$(test_name()) deep_v: $(deep_v)")

                    top_v += 1
                    mid_v += 1
                    deep_v += 1

                    return nothing
                end
            end

            return nothing
        end

        return nothing
    end

    return nothing
end

@test_throws "top/... : 1 failed out of 5 test cases" begin
    println("Ignore the test failure:")
    all_tests()
end

@test lines == [
    "---",
    "top top_v: 1",
    "top/mid_1 top_v: 1",
    "top/mid_1 mid_v: 1",
    "---",
    "top top_v: 1",
    "top/mid_2 top_v: 1",
    "top/mid_2 mid_v: 1",
    "top/mid_2/deep_1 top_v: 1",
    "top/mid_2/deep_1 mid_v: 1",
    "top/mid_2/deep_1 deep_v: 1",
    "---",
    "top top_v: 1",
    "top/mid_2 top_v: 1",
    "top/mid_2 mid_v: 1",
    "top/mid_2/deep_2 top_v: 1",
    "top/mid_2/deep_2 mid_v: 1",
    "top/mid_2/deep_2 deep_v: 1",
    "---",
    "top top_v: 1",
    "top/mid_2 top_v: 1",
    "top/mid_2 mid_v: 1",
    "---",
    "top top_v: 1",
]

empty!(lines)

@test_throws "top/... : 1 failed out of 1 test cases" begin
    println("Ignore the test failure:")
    abort_on_first_failure(true)
    all_tests()
end
abort_on_first_failure(false)

@test lines == ["---", "top top_v: 1", "top/mid_1 top_v: 1", "top/mid_1 mid_v: 1"]

empty!(lines)

test_prefixes(["other"])
all_tests()
@test isempty(lines)

test_prefixes(["top/mid_2"])
println("\nExpect no test failures:")
all_tests()

@test lines == [
    "---",
    "top top_v: 1",
    "---",
    "top top_v: 1",
    "top/mid_2 top_v: 1",
    "top/mid_2 mid_v: 1",
    "top/mid_2/deep_1 top_v: 1",
    "top/mid_2/deep_1 mid_v: 1",
    "top/mid_2/deep_1 deep_v: 1",
    "---",
    "top top_v: 1",
    "top/mid_2 top_v: 1",
    "top/mid_2 mid_v: 1",
    "top/mid_2/deep_2 top_v: 1",
    "top/mid_2/deep_2 mid_v: 1",
    "top/mid_2/deep_2 deep_v: 1",
    "---",
    "top top_v: 1",
    "top/mid_2 top_v: 1",
    "top/mid_2 mid_v: 1",
    "---",
    "top top_v: 1",
]
