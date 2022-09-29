struct Citation <: AbstractBlock
    id::String
    brackets::Bool
end

struct CitationBracket <: AbstractBlock end

struct CitationRule
    cites::Vector{Node}
    CitationRule() = new([])
end

inline_rule(rule::CitationRule) = Rule(1, "@") do parser, block
    m = consume(parser, match(r"@[_\w\d][_\w\d:#$%&\-\+\?\<\>~/]*", parser))
    m === nothing && return false
    bs = parser.brackets
    opener = bs !== nothing && is_bracket(bs.node, "[")
    citation = Node(Citation(chop(m.match; head=1, tail=0), opener))
    citation.literal = m.match
    append_child(block, citation)
    push!(rule.cites, citation)
    return true
end

is_bracket(n::Node, c) = n.literal == c && n.t isa Text

inline_modifier(rule::CitationRule) = Rule(1) do parser, block
    openers = Set{Node}()
    closers = Set{Node}()
    while !isempty(rule.cites)
        cite = pop!(rule.cites)
        if cite.t.brackets
            opener = closer = cite
            while !isnull(opener.prv)
                opener = opener.prv
                opener in openers && @goto SKIP
                opener.t isa Citation && break
                if is_bracket(opener, "[")
                    opener.t = CitationBracket()
                    push!(openers, opener)
                    break
                end
            end
            while !isnull(closer.nxt)
                closer = closer.nxt
                closer in closers && @goto SKIP
                closer.t isa Citation && break
                if is_bracket(closer, "]")
                    closer.t = CitationBracket()
                    push!(closers, closer)
                    break
                end
            end
            @label SKIP
        end
    end
end

struct References <: AbstractBlock end

block_modifier(::CitationRule) = Rule(10) do parser, b
    if !isnull(b.parent) && b.parent.t isa Document
        if haskey(b.meta, "id") && b.meta["id"] == "refs"
            insert_after(b, Node(References()))
        end
    end
    return nothing
end

# Writers. TODO: implement real CSL for citation styling.

function write_html(c::Citation, w, n, ent)
    tag(w, "span", attributes(w, n, ["class" => "citation"]))
    tag(w, "a", ["href" => "#ref-$(c.id)"])
    literal(w, CSL.author_year(w.env, c.id))
    tag(w, "/a")
    tag(w, "/span")
end

function write_latex(c::Citation, w, n, ent)
    if ent
        # Allow the latex writer environment to control how citations are
        # printed. `basic` just uses the built in hyperlinking similar to the
        # HTML writer. `biblatex` will generate citations suitable for use with
        # `biblatex` and `biber`.
        if get(w.env, "citations", "basic") == "biblatex"
            literal(w, "\\cite{", c.id, "}")
        else
            name = CSL.author_year(w.env, c.id)
            name = name === nothing ? c.id : name
            literal(w, "\\protect\\hyperlink{ref-", c.id, "}{", name, "}")
        end
    end
    return nothing
end

write_markdown(c::Citation, w, n, ent) = literal(w, "@", c.id)

function write_term(c::Citation, w, n, ent)
    style = crayon"red"
    print_literal(w, style)
    push_inline!(w, style)
    print_literal(w, CSL.author_year(w.env, c.id))
    pop_inline!(w)
    print_literal(w, inv(style))
end

write_html(::CitationBracket, w, n, ent) = literal(w, n.literal == "[" ? "(" : ")")
write_latex(::CitationBracket, w, n, ent) = literal(w, n.literal == "[" ? "(" : ")")
write_markdown(::CitationBracket, w, n, ent) = literal(w, n.literal)
write_term(::CitationBracket, w, n, ent) = print_literal(w, n.literal == "[" ? "(" : ")")

write_markdown(::References, w, n, ent) = nothing
write_html(::References, w, n, ent) = write_references(write_html, w)
write_latex(::References, w, n, ent) = write_references(write_latex, w)
write_term(::References, w, n, ent) = write_references(write_term, w)

function write_references(f, writer)
    ast = build_references(get(writer.env, "references", nothing))
    f(writer, ast)
end

struct ReferenceList <: AbstractBlock
end

is_container(::ReferenceList) = true

write_markdown(::ReferenceList, w, n, ent) = nothing
write_html(::ReferenceList, w, n, ent) = nothing
write_latex(::ReferenceList, w, n, ent) = nothing
write_term(::ReferenceList, w, n, ent) = nothing

function build_references(items::AbstractVector)
    block = Node(ReferenceList())
    for item in sort!(items; by=CSL.authors_long)
        append_child(block, build_reference(item))
    end
    return block
end
build_references(::Nothing) = Node(ReferenceList())

function build_reference(item::AbstractDict)
    paragraph = Node(Paragraph())
    paragraph.meta["id"] = "ref-$(get(item, "id", ""))"
    # Authors.
    authors = CSL.authors_long(item)
    authors === nothing || append_child(paragraph, text("$authors. "))
    # Year of publication.
    year = CSL.year(item)
    year === nothing || append_child(paragraph, text("$year. "))
    # Title of document.
    title = Node(Emph())
    append_child(title, text(CSL.title(item) * ". "))
    append_child(paragraph, title)
    # Publisher and location of publication.
    publisher = CSL.publisher(item)
    publisher === nothing || append_child(paragraph, text("$publisher. "))
    # Digital object identifier.
    doi = CSL.doi(item)
    doi === nothing || append_child(paragraph, text("doi:$doi. "))
    # Document URL.
    url = CSL.url(item)
    if url !== nothing
        link = Node(Link())
        link.t.title = url
        link.t.destination = url
        append_child(link, text(url))
        append_child(paragraph, link)
        append_child(paragraph, text(". "))
    end
    return paragraph
end

module CSL

rget(f, col, key, keys...) = contains(col, key) ? rget(f, col[key], keys...) : f()
rget(f, col, key) = tryget(f, col, key)
tryget(f, d, key) = contains(d, key) ? d[key] : f()
contains(d::AbstractDict, key) = haskey(d, key)
contains(v::AbstractVector, index) = index in keys(v)
contains(others...) = false

year(item) = rget(() -> nothing, item, "issued", "date-parts", 1, 1)
authors(item) = filter(d -> d isa Dict && haskey(d, "family"), rget(() -> [], item, "author"))
title(item) = rget(() -> nothing, item, "title")

function year(env::AbstractDict, id::AbstractString)
    y = year(get_item(env, id))
    return y === nothing ? "@$id" : y
end

author_short(item) = get(() -> get(item, "given", ""), item, "family")

function authors_short(item)
    names = sort(authors(item); by=author_short)
    n = length(names)
    n === 0   && return "Unknown"
    1 ≤ n ≤ 2 && return join(author_short.(names), " and ")
    n === 3   && return join(author_short.(names), ", ", ", and ")
    return author_short(names[1]) * " et al."
end

function author_long(item, first)
    family = get(item, "family", "")
    given = get(item, "given", "")
    given == "" && return family
    family == "" && return given
    return first ? "$family, $given" : "$given $family"
end

function authors_long(item)
    names = sort(authors(item); by=author_short)
    return join((author_long(a, n==1) for (n, a) in enumerate(names)), ", ", ", and ")
end

mapbib(items::AbstractVector) = Dict{String,Dict}(item["id"] => item for item in items if haskey(item, "id"))

function get_item(env, id)
    if haskey(env, "references")
        refs = get!(() -> mapbib(env["references"]), env, "ref-map")
        haskey(refs, id) && return refs[id]
    end
    return nothing
end

function author_year(env::AbstractDict, id::AbstractString)
    item = get_item(env, id)
    return item === nothing ? "@$id" : author_year(item)
end
author_year(item) = "$(authors_short(item)) $(year(item))"

publisher(d) = _publisher(get(d, "publisher-place", nothing), get(d, "publisher", nothing))
_publisher(place, name) = "$place: $name"
_publisher(::Nothing, name::AbstractString) = name
_publisher(place::AbstractString, ::Nothing) = place
_publisher(::Nothing, ::Nothing) = nothing

url(d) = get(d, "URL", nothing)
doi(d) = get(d, "DOI", nothing)

end
