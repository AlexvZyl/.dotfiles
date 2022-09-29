function writer(mime, file::AbstractString, ast::Node, env=Dict{String,Any}())
    env = merge(env, Dict("outputfile" => file))
    open(io -> writer(io, mime, ast, env), file, "w")
end
writer(mime, io::IO, ast::Node, env=nothing) = writer(io, mime, ast, env)
writer(mime, ast::Node, env=nothing) = sprint(writer, mime, ast, env)

function writer(io::IO, mime::MIME, ast::Node, env::Dict)
    # Merge all metadata provided, priority is right-to-left.
    env = recursive_merge(default_config(), env, frontmatter(ast), ast.meta)
    if haskey(env, "template-engine")
        temp = template(env, mime_to_str(mime))
        # Empty templates will skip the template rendering step.
        if !isempty(temp)
            env["body"] = sprint(show, mime, ast, env)
            env["template-engine"](io, temp, env; tags=("\${", "}"))
            return nothing
        end
    end
    show(io, mime, ast, env)
end
writer(io::IO, mime::MIME, ast::Node, ::Nothing) = show(io, mime, ast)

default_config() = Dict{String,Any}(
    "authors" => [],
    "curdir" => pwd(),
    "title" => "",
    "subtitle" => "",
    "abstract" => "",
    "keywords" => [],
    "lang" => "en",
    "latex" => Dict{String,Any}(
        "documentclass" => "article",
    ),
)

_smart_link(mime, obj, node, env) = haskey(env, "smartlink-engine") ?
    env["smartlink-engine"](mime, obj, node, env) : obj

function template(env, fmt)
    # Template load order:
    #
    # - <fmt>.template.string
    # - <fmt>.template.file
    # - TEMPLATES["<fmt>"]
    #
    config = get(() -> Dict{String, Any}(), env, fmt)
    tmp = get(() -> Dict{String, Any}(), config, "template")
    get(tmp, "string") do
        haskey(tmp, "file") ? read(tmp["file"], String) :
        haskey(TEMPLATES, fmt) ? read(TEMPLATES[fmt], String) : ""
    end
end
const TEMPLATES = Dict{String,String}()

recursive_merge(ds::AbstractDict...) = merge(recursive_merge, ds...)
recursive_merge(args...) = last(args)

frontmatter(n::Node) = has_frontmatter(n) ? n.first_child.t.data : Dict{String,Any}()
has_frontmatter(n::Node) = !isnull(n.first_child) && n.first_child.t isa FrontMatter

mutable struct Writer{F, I <: IO}
    format::F
    buffer::I
    last::Char
    enabled::Bool
    context::Dict{Symbol, Any}
    env::Dict{String,Any}
end
Writer(format, buffer=IOBuffer(), env=Dict{String,Any}()) = Writer(format, buffer, '\n', true, Dict{Symbol, Any}(), env)

Base.get(w::Writer, k::Symbol, default) = get(w.context, k, default)
Base.get!(f::Function, w::Writer, k::Symbol) = get!(f, w.context, k)

function literal(r::Writer, args...)
    if r.enabled
        for arg in args
            write(r.buffer, arg)
            r.last = isempty(arg) ? r.last : last(arg)
        end
    end
    return nothing
end

function cr(r::Writer)
    if r.enabled && r.last != '\n'
        r.last = '\n'
        write(r.buffer, '\n')
    end
    return nothing
end

function _syntax_highlighter(w::Writer, mime::MIME, node::Node, escape=identity)
    key = "syntax-highlighter"
    return haskey(w.env, key) ? w.env[key](mime, node) : escape(node.literal)
end

include("writers/html.jl")
include("writers/latex.jl")
include("writers/term.jl")
include("writers/markdown.jl")
include("writers/notebook.jl")

function ast_dump(io::IO, ast::Node)
    indent = -2
    for (node, enter) in ast
        T = typeof(node.t).name.name
        if is_container(node)
            indent += enter ? 2 : -2
            enter && printstyled(io, ' '^indent, T, "\n"; color=:blue)
        else
            printstyled(io, ' '^(indent + 2), T, "\n"; bold=true, color=:red)
            println(io, ' '^(indent + 4), repr(node.literal))
        end
    end
end
ast_dump(ast::Node) = ast_dump(stdout, ast)
