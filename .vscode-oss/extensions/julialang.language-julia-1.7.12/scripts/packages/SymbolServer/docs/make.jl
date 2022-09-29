using SymbolServer
using Documenter

makedocs(;
    modules=[SymbolServer],
    authors="Julia VSCode",
    repo="https://github.com/julia-vscode/SymbolServer.jl/blob/{commit}{path}#L{line}",
    sitename="SymbolServer.jl",
    format=Documenter.HTML(;
        prettyurls=prettyurls = get(ENV, "CI", nothing) == "true",
        # canonical="https://www.julia-vscode.org/SymbolServer.jl",
        # assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Syntax Reference" => "syntax.md",
    ],
)

deploydocs(;
    repo="github.com/julia-vscode/SymbolServer.jl",
)
