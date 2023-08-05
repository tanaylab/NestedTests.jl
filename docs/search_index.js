var documenterSearchIndex = {"docs":
[{"location":"index.html#NestedTests","page":"NestedTests","title":"NestedTests","text":"","category":"section"},{"location":"index.html","page":"NestedTests","title":"NestedTests","text":"NestedTests\nNestedTests.@nested_test\nNestedTests.test_name\nNestedTests.test_prefixes","category":"page"},{"location":"index.html#NestedTests","page":"NestedTests","title":"NestedTests","text":"Run tests in nested environments.\n\n\n\n\n\n","category":"module"},{"location":"index.html#NestedTests.@nested_test","page":"NestedTests","title":"NestedTests.@nested_test","text":"@nested_test(name::String) do ... end\n\nRun tests in a nested environment. The test can use any of the variables defined in its parent test(s). Any changes made to these variables will be isolated from other sibling nested tests in this level, but will be visible to descendant nested tests.\n\n\n\n\n\n","category":"macro"},{"location":"index.html#NestedTests.test_name","page":"NestedTests","title":"NestedTests.test_name","text":"test_name()::String\n\nReturn the full name of the current test, with / separating the nested test names.\n\n\n\n\n\n","category":"function"},{"location":"index.html#NestedTests.test_prefixes","page":"NestedTests","title":"NestedTests.test_prefixes","text":"test_prefixes(prefixes::Vector{Union{String}})::Nothing\n\nSpecify prefixes for the tests to run. Only tests whose test_name matches any of these prefixes will be run. If the vector is empty (the default), all the tests will be run.\n\n\n\n\n\n","category":"function"}]
}