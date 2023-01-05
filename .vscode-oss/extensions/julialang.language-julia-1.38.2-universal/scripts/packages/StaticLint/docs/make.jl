using StaticLint
using Documenter

makedocs(;
    modules=[StaticLint],
    authors="Julia VSCode",
    repo="https://github.com/julia-vscode/StaticLint.jl/blob/{commit}{path}#L{line}",
    sitename="StaticLint.jl",
    format=Documenter.HTML(;
        prettyurls=prettyurls = get(ENV, "CI", nothing) == "true",
        # canonical="https://www.julia-vscode.org/StaticLint.jl",
        # assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Syntax Reference" => "syntax.md",
    ],
)

deploydocs(;
    repo="github.com/julia-vscode/StaticLint.jl",
)
