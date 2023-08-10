# NestedTests v0.2.0 - run tests in nested environments.

See the [v0.2.0 documentation](https://tanaylab.github.io/NestedTests.jl/v0.2.0) for details.

## Motivation

When creating a test suite, it is often the case that many tests share the same setup (and teardown) code. In
particular, it is often the case that the tests form a tree, where some setup is common to many tests, and additional
setup is common to a subset of the tests, and so on until reaching the leaf test cases of this tree.

This package is built around this concept. It runs all the leaf test cases, and for each one, it runs all the setup code
needed for it, from scratch. That is, all the tests cases are isolated from each other and can freely modify the
prepared test data.

The main function of this package is [`nested_test`](@ref), which introduces a new sub-test to run. In addition, you can
always get the full path name of the current test environment using [`test_name`](@ref). For example, consider the
following:

```julia
nested_test("top") do
    db = create_temporary_database()
    @assert test_name() == "top"
    @test is_valid_database(db)

    nested_test("simple operations") do
        @assert test_name() == "top/simple operations"
        fill_simple_operations_data(db)
        @test simple_operations_work(db)
    end

    nested_test("complex operations") do
        @assert test_name() == "top/complex operations"
        fill_complex_operations_data(db)
        @test complex_operations_work(db)
    end
end
```

The framework will run both the simple operations tests and the complex operations tests. Nested test cases have full
access to the variables introduced in their parent, following Julia's nested variable scopes; this allows both leaf test
cases to access the `db` variable from the top level test case. However, the framework will re-run things so that each
of the leaf tests will get a fresh database, isolating the leaf tests from each other. If a parent test case fails for
any reason (including failed `@test` assertions), then its child tests are skipped.

You can also restrict the set of test cases that will be executed by specifying a list of prefixes, e.g.
`test_prefixes(["top"])` will restrict the executed tests to only cases nested under `top`.

NOTE: Don't try to wrap `nested_test` inside a `@testset` - it won't work since `@testset` takes over the failed `@test`
assertions making it difficult for the `nested_test` to tell when a test case failed. It would have been nice to
integrate both systems so that each nested test case would be a `@testset`, or at least the top-level nested test case
would be, but this requires deep integration with the implementation of `@testset`. If someone wants to take a stab at
this, pull requests are welcome :-) For now we print the total number of passed/failed test cases (not `@test`
assertions) at the end, together with the elapsed time.

## Installation

Just `Pkg.add("NestedTests")`, like installing any other Julia package.

## License (MIT)

Copyright © 2023 Weizmann Institute of Science

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
