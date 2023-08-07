# This file is copied into `docs` so that when the package is published its documentation will be built automatically,
# that is, pretend the package uses the usual "docs/make.jl" idiom. Normally this isn't used because we build the
# documentation locally and publish them in github pages. This way, in github we have the head version documentation,
# while in the standard Julia packages documentation we have the documentation of the last published version.

using Documenter

push!(LOAD_PATH, "..")

using NestedTests

for file in readdir("docs"; join = true)
    if !endswith(file, "make.jl")
        rm(file; force = true, recursive = true)
    end
end

makedocs(;
    authors = "Oren Ben-Kiki",
    repo = "https://github.com/tanaylab/NestedTests.jl/blob/main{path}?plain=1#L{line}",
    source = "../src",
    clean = true,
    doctest = true,
    modules = [NestedTests],
    highlightsig = true,
    sitename = "NestedTests.jl",
    draft = false,
    strict = true,
    linkcheck = true,
    format = Documenter.HTML(; prettyurls = false),
    pages = ["index.md"],
)

for file in readdir("docs/build"; join = true)
    if endswith(file, ".cov")
        rm(file)
    end
end
