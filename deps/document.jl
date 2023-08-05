using Documenter
using Logging
using LoggingExtras

seen_problems = false

detect_problems = EarlyFilteredLogger(global_logger()) do log_args
    if log_args.level >= Logging.Warn
        global seen_problems
        seen_problems = true
    end
    return true
end

global_logger(detect_problems)

push!(LOAD_PATH, ".")

using NestedTests

makedocs(;
    authors = "Oren Ben-Kiki",
    repo = "https://github.com/tanaylab/NestedTests.jl/blob/main{path}?plain=1#L{line}",
    build = "../docs",
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

if seen_problems
    exit(1)
end
