struct FootnoteRule
    cache::Dict{String, Node}
    FootnoteRule() = new(Dict())
end
block_rule(fr::FootnoteRule) = Rule(0.5, "[") do parser, container
    if !parser.indented
        ln = SubString(parser.buf, parser.next_nonspace)
        m = match(r"^\[\^([\w\d]+)\]:[ ]?", ln)
        if m !== nothing
            close_unmatched_blocks(parser)
            fr.cache[m[1]] = add_child(parser, FootnoteDefinition(m[1]), parser.next_nonspace)
            advance_offset(parser, length(m.match), false)
            return 1
        end
    end
    return 0
end
inline_rule(fr::FootnoteRule) = Rule(0.5, "[") do p, node
    m = consume(p, match(r"^\[\^([\w\d]+)]", p))
    m === nothing && return false
    append_child(node, Node(FootnoteLink(m[1], fr)))
    return true
end

struct FootnoteDefinition <: AbstractBlock
    id::String
end

struct FootnoteLink <: AbstractInline
    id::String
    rule::FootnoteRule
end

is_container(::FootnoteDefinition) = true
accepts_lines(::FootnoteDefinition) = false
can_contain(::FootnoteDefinition, t) = !(t isa Item)
finalize(::FootnoteDefinition, ::Parser, ::Node) = nothing
function continue_(::FootnoteDefinition, parser::Parser, ::Any)
    if parser.indent ≥ 4
        advance_offset(parser, 4, true)
    elseif parser.blank
        advance_next_nonspace(parser)
    else
        return 1
    end
    return 0
end

#
# Writers
#

# Definitions

function write_html(f::FootnoteDefinition, rend, node, enter)
    if enter
        tag(rend, "div", attributes(rend, node, ["class" => "footnote", "id" => "footnote-$(f.id)"]))
        tag(rend, "p", ["class" => "footnote-title"])
        print(rend.buffer, f.id)
        tag(rend, "/p")
    else
        tag(rend, "/div")
    end
end

function write_latex(f::FootnoteDefinition, w, node, enter)
    get(w.buffer, :footnote, false) || (w.enabled = !enter)
    return nothing
end

function write_term(f::FootnoteDefinition, rend, node, enter)
    style = crayon"red"
    if enter
        header = rpad("┌ [^$(f.id)] ", available_columns(rend), "─")
        print_margin(rend)
        print_literal(rend, style, header, inv(style), "\n")
        push_margin!(rend, "│", style)
        push_margin!(rend, " ", crayon"")
    else
        pop_margin!(rend)
        pop_margin!(rend)
        print_margin(rend)
        print_literal(rend, style, rpad("└", available_columns(rend), "─"), inv(style), "\n")
        if !isnull(node.nxt)
            print_margin(rend)
            print_literal(rend, "\n")
        end
    end
end

function write_markdown(f::FootnoteDefinition, w, node, ent)
    if ent
        push_margin!(w, 1, "[^$(f.id)]: ", " "^4)
    else
        pop_margin!(w)
        cr(w)
    end
end

# Links

function write_html(f::FootnoteLink, rend, node, enter)
    tag(rend, "a", attributes(rend, node, ["href" => "#footnote-$(f.id)", "class" => "footnote"]))
    print(rend.buffer, f.id)
    tag(rend, "/a")
end

function write_latex(f::FootnoteLink, w, node, enter)
    if haskey(f.rule.cache, f.id)
        seen = get!(() -> Set{String}(), w, :footnotes)
        if f.id in seen
            literal(w, "\\footref{fn:$(f.id)}")
        else
            push!(seen, f.id)
            literal(w, "\\footnote{")
            latex(IOContext(w.buffer, :footnote => true), f.rule.cache[f.id])
            literal(w, "\\label{fn:$(f.id)}}")
        end
    end
    return nothing
end

function write_term(f::FootnoteLink, rend, node, enter)
    style = crayon"red"
    print_literal(rend, style)
    push_inline!(rend, style)
    print_literal(rend, "[^", f.id, "]")
    pop_inline!(rend)
    print_literal(rend, inv(style))
end

write_markdown(f::FootnoteLink, w, node, ent) = literal(w, "[^", f.id, "]")
