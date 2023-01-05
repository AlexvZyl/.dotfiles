using Documenter
using OrderedCollections


makedocs(
    format = :html,
    sitename = "OrderedCollections.jl",
    pages = [
        "index.md",
        "ordered_containers.md",
    ]
)

deploydocs(
    repo = "github.com/JuliaCollections/OrderedCollections.jl.git",
    julia  = "0.7",
    latest = "master",
    target = "build",
    deps = nothing,  # we use the `format = :html`, without `mkdocs`
    make = nothing,  # we use the `format = :html`, without `mkdocs`
)
