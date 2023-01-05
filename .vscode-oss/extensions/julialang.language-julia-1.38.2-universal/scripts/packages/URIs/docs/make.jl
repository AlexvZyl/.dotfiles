using Documenter, URIs

makedocs(;
    modules=[URIs],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/JuliaWeb/URIs.jl/blob/{commit}{path}#L{line}",
    sitename="URIs.jl",
    authors = "Jacob Quinn, Sam O'Connor and contributors: https://github.com/JuliaWeb/URIs.jl/graphs/contributors"
)

deploydocs(;
    repo="github.com/JuliaWeb/URIs.jl",
    push_preview=true
)
