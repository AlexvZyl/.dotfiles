# Public.

function Base.show(io::IO, ::MIME"text/html", ast::Node, env=Dict{String,Any}())
    writer = Writer(HTML(), io, env)
    write_html(writer, ast)
    return nothing
end
html(args...) = writer(MIME"text/html"(), args...)

# Internals.

mime_to_str(::MIME"text/html") = "html"

TEMPLATES["html"] = joinpath(@__DIR__, "templates/html.mustache")

mutable struct HTML
    disable_tags::Int
    softbreak::String
    safe::Bool
    sourcepos::Bool

    function HTML(; softbreak="\n", safe=false, sourcepos=false)
        format = new()
        format.disable_tags = 0
        format.softbreak = softbreak # Set to "<br />" to for hardbreaks, " " for no wrapping.
        format.safe = safe
        format.sourcepos = sourcepos
        return format
    end
end

function write_html(writer::Writer, ast::Node)
    for (node, entering) in ast
        write_html(node.t, writer, node, entering)
    end
end

const reUnsafeProtocol = r"^javascript:|vbscript:|file:|data:"i
const reSafeDataProtocol = r"^data:image\/(?:png|gif|jpeg|webp)"i

potentially_unsafe(url) = occursin(reUnsafeProtocol, url) && !occursin(reSafeDataProtocol, url)

function tag(r::Writer, name, attributes=[], self_closing=false)
    r.format.disable_tags > 0 && return nothing
    literal(r, '<', name)
    for (key, value) in attributes
        literal(r, " ", key, '=', '"', value, '"')
    end
    self_closing && literal(r, " /")
    literal(r, '>')
    r.last = '>'
    return nothing
end

write_html(::Document, r, n, ent) = nothing

write_html(::Text, r, n, ent) = literal(r, escape_xml(n.literal))

write_html(::Backslash, w, node, ent) = nothing

write_html(::SoftBreak, r, n, ent) = literal(r, r.format.softbreak)

function write_html(::LineBreak, r, n, ent)
    tag(r, "br", attributes(r, n), true)
    cr(r)
end

function write_html(link::Link, r, n, ent)
    if ent
        attrs = []
        if !(r.format.safe && potentially_unsafe(link.destination))
            link = _smart_link(MIME"text/html"(), link, n, r.env)
            push!(attrs, "href" => escape_xml(link.destination))
        end
        if !isempty(link.title)
            push!(attrs, "title" => escape_xml(link.title))
        end
        tag(r, "a", attributes(r, n, attrs))
    else
        tag(r, "/a")
    end
end

function write_html(image::Image, r, n, ent)
    if ent
        if r.format.disable_tags == 0
            if r.format.safe && potentially_unsafe(image.destination)
                literal(r, "<img src=\"\" alt=\"")
            else
                image = _smart_link(MIME"text/html"(), image, n, r.env)
                literal(r, "<img src=\"", escape_xml(image.destination), "\" alt=\"")
            end
        end
        r.format.disable_tags += 1
    else
        r.format.disable_tags -= 1
        if r.format.disable_tags == 0
            if image.title !== nothing && !isempty(image.title)
                literal(r, "\" title=\"", escape_xml(image.title))
            end
            literal(r, "\" />")
        end
    end
end

write_html(::Emph, r, n, ent) = tag(r, ent ? "em" : "/em", ent ? attributes(r, n) : [])

write_html(::Strong, r, n, ent) = tag(r, ent ? "strong" : "/strong", ent ? attributes(r, n) : [])

function write_html(::Paragraph, r, n, ent)
    grandparent = n.parent.parent
    if !isnull(grandparent) && grandparent.t isa List
        if grandparent.t.list_data.tight
            return
        end
    end
    if ent
        attrs = attributes(r, n)
        cr(r)
        tag(r, "p", attrs)
    else
        tag(r, "/p")
        cr(r)
    end
end

function write_html(::Heading, r, n, ent)
    tagname = "h$(n.t.level)"
    if ent
        attrs = attributes(r, n)
        cr(r)
        tag(r, tagname, attrs)
        # Insert auto-generated anchor Links for all Headings with IDs.
        # The Link is not added to the document's AST.
        if haskey(n.meta, "id")
            anchor = Node(Link())
            anchor.t.destination = "#" * n.meta["id"]
            anchor.meta["class"] = ["anchor"]
            write_html(r, anchor)
        end
    else
        tag(r, "/$(tagname)")
        cr(r)
    end
end

function write_html(::Code, r, n, ent)
    tag(r, "code", attributes(r, n))
    literal(r, escape_xml(n.literal))
    tag(r, "/code")
end

function write_html(::CodeBlock, r, n, ent)
    info_words = split(n.t.info === nothing ? "" : n.t.info)
    attrs = attributes(r, n)
    if !isempty(info_words) && !isempty(first(info_words))
        push!(attrs, "class" => "language-$(escape_xml(first(info_words)))")
    end
    cr(r)
    tag(r, "pre")
    tag(r, "code", attrs)
    literal(r, _syntax_highlighter(r, MIME("text/html"), n, escape_xml))
    tag(r, "/code")
    tag(r, "/pre")
    cr(r)
end

function write_html(::ThematicBreak, r, n, ent)
    attrs = attributes(r, n)
    cr(r)
    tag(r, "hr", attrs, true)
    cr(r)
end

function write_html(::BlockQuote, r, n, ent)
    if ent
        attrs = attributes(r, n)
        cr(r)
        tag(r, "blockquote", attrs)
        cr(r)
    else
        cr(r)
        tag(r, "/blockquote")
        cr(r)
    end
end

function write_html(::List, r, n, ent)
    tagname = n.t.list_data.type === :bullet ? "ul" : "ol"
    if ent
        attrs = attributes(r, n)
        start = n.t.list_data.start
        if start !== nothing && start != 1
            push!(attrs, "start" => string(start))
        end
        cr(r)
        tag(r, tagname, attrs)
        cr(r)
    else
        cr(r)
        tag(r, "/$(tagname)")
        cr(r)
    end
end

function write_html(::Item, r, n, ent)
    if ent
        attrs = attributes(r, n)
        tag(r, "li", attrs)
    else
        tag(r, "/li")
        cr(r)
    end
end

write_html(::HtmlInline, r, n, ent) = literal(r, r.format.safe ? "<!-- raw HTML omitted -->" : n.literal)

function write_html(::HtmlBlock, r, n, ent)
    cr(r)
    literal(r, r.format.safe ? "<!-- raw HTML omitted -->" : n.literal)
    cr(r)
end

function attributes(r, n, out=[])
    if r.format.sourcepos
        if n.sourcepos !== nothing
            p = n.sourcepos
            push!(out, "data-sourcepos" => "$(p[1][1]):$(p[1][2])-$(p[2][1]):$(p[2][2])")
        end
    end
    for (key, value) in n.meta
        value = key == "class" ? join(value, " ") : value
        push!(out, key => value)
    end
    return out
end
