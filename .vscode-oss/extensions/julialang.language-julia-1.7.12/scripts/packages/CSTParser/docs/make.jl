using CSTParser
using Documenter

makedocs(;
    modules=[CSTParser],
    authors="Julia VSCode",
    repo="https://github.com/julia-vscode/CSTParser.jl/blob/{commit}{path}#L{line}",
    sitename="CSTParser.jl",
    format=Documenter.HTML(;
        prettyurls=prettyurls = get(ENV, "CI", nothing) == "true",
        # canonical="https://www.julia-vscode.org/CSTParser.jl",
        # assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Syntax Reference" => "syntax.md",
    ],
)

deploydocs(;
    repo="github.com/julia-vscode/CSTParser.jl",
)
