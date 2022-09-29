# Public.

function Base.show(io::IO, ::MIME"application/x-ipynb+json", ast::Node, env=Dict{String,Any}())
    json = Dict(
        "cells" => [],
        "metadata" => Dict(
            "kernelspec" => Dict(
                "display_name" => "Julia $VERSION",
                "language" => "julia",
                "name" => "julia-$VERSION",
            ),
            "language_info" => Dict(
                "file_extension" => ".jl",
                "mimetype" => "application/julia",
                "name" => "julia",
                "version" => "$VERSION",
            ),
        ),
        "nbformat" => 4,
        "nbformat_minor" => 4,
    )
    for (node, enter) in ast
        write_notebook(json, node, enter, env)
    end
    JSON.Writer.print(io, json)
    return nothing
end
notebook(args...) = writer(MIME"application/x-ipynb+json"(), args...)

# Internal.

mime_to_str(::MIME"application/x-ipynb+json") = "notebook"

function write_notebook(json, node, enter, env)
    split_lines = str -> collect(eachline(IOBuffer(str); keep=true))
    if !isnull(node) && node.t isa CodeBlock && node.parent.t isa Document && node.t.info == "julia"
        # Toplevel Julia codeblocks become code cells.
        cell = Dict(
            "cell_type" => "code",
            "execution_count" => nothing,
            "metadata" => Dict(),
            "source" => split_lines(rstrip(node.literal, '\n')),
            "outputs" => [],
        )
        push!(json["cells"], cell)
    elseif !isnull(node.parent) && node.parent.t isa Document && enter
        # All other toplevel turns into markdown cells.
        cells = json["cells"]
        if !isempty(cells) && cells[end]["cell_type"] == "markdown"
            # When we already have a current markdown cell then append content.
            append!(cells[end]["source"], split_lines(markdown(node, env)))
        else
            # ... otherwise open a new cell.
            cell = Dict(
                "cell_type" => "markdown",
                "metadata" => Dict(),
                "source" => split_lines(markdown(node)),
            )
            push!(cells, cell)
        end
    end
end
