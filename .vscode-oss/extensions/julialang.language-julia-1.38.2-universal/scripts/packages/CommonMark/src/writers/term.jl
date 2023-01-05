# Public.

function Base.show(io::IO, ::MIME"text/plain", ast::Node, env=Dict{String,Any}())
    writer = Writer(Term(), io, env)
    write_term(writer, ast)
    # Writing is done to an intermediate buffer and then written to the
    # user-provided one once we have traversed the AST so that we can avoid
    # noticable lag when displaying on the terminal.
    write(writer.buffer, take!(writer.format.buffer))
    return nothing
end
term(args...) = writer(MIME"text/plain"(), args...)

# Internals.

mime_to_str(::MIME"text/plain") = "term"

import Crayons: Crayon, @crayon_str

mutable struct MarginSegment
    text::String
    width::Int
    count::Int
end

mutable struct Term
    indent::Int
    margin::Vector{MarginSegment}
    buffer::IOBuffer
    wrap::Int
    list_depth::Int
    list_item_number::Vector{Int}
    Term() = new(0, [], IOBuffer(), -1, 0, [])
end

function write_term(writer::Writer, ast::Node)
    for (node, entering) in ast
        write_term(node.t, writer, node, entering)
    end
end

# Utilities.

function padding_between(cols, objects)
    count = length(objects) - 1
    nchars = sum(Base.Unicode.textwidth, objects)
    return (cols - nchars) ÷ count
end
padding_between(cols, width::Integer) = (cols - width) ÷ 2

"""
What is the width of the literal text stored in `node` and all of it's child
nodes. Used to determine alignment for rendering nodes such as centered.
"""
function literal_width(node::Node)
    width = 0
    for (node, enter) in node
        if enter
            width += Base.Unicode.textwidth(node.literal)
        end
    end
    return width
end

const LEFT_MARGIN = " "

"""
Given the current indent of the renderer we check to see how much space is left
on the current line.
"""
function available_columns(r::Writer{Term})
    _, cols = displaysize(r.buffer)
    return cols - r.format.indent - length(LEFT_MARGIN)
end

"""
Adds a new segment to the margin buffer. This segment is persistent and thus
will print on every margin print.
"""
function push_margin!(r::Writer, text::AbstractString, style=crayon"")
    return push_margin!(r, -1, text, style)
end

"""
Adds new segmant to the margin buffer. `count` determines how many time
`initial` is printed. After that, the width of `rest` is printed instead.
"""
function push_margin!(r::Writer, count::Integer, initial::AbstractString, rest::AbstractString)
    width = Base.Unicode.textwidth(rest)
    r.format.indent += width
    seg = MarginSegment(initial, width, count)
    push!(r.format.margin, seg)
    return nothing
end

"""
Adds a new segment to the margin buffer, but will only print out for the given
number of `count` calls to `print_margin`. After `count` calls it will instead
print out spaces equal to the width of `text`.
"""
function push_margin!(r::Writer, count::Integer, text::AbstractString, style=crayon"")
    width = Base.Unicode.textwidth(text)
    text = string(style, text, inv(style))
    r.format.indent += width
    seg = MarginSegment(text, width, count)
    push!(r.format.margin, seg)
    return nothing
end

# Matching call for a `push_margin!`. Must be call on exiting a node where a
# `push_margin!` was used when entering.
function pop_margin!(r::Writer)
    seg = pop!(r.format.margin)
    r.format.indent -= seg.width
    return nothing
end

function push_inline!(r::Writer, style)
    push!(r.format.margin, MarginSegment(string(style), 0, -1))
    pushfirst!(r.format.margin, MarginSegment(string(inv(style)), 0, -1))
    return nothing
end

function pop_inline!(r::Writer)
    pop!(r.format.margin)
    popfirst!(r.format.margin)
    return nothing
end

"""
Print out all the current segments present in the margin buffer.

Each time a segment gets printed it's count is reduced. When a segment has a
count of zero it won't be printed and instead spaces equal to it's width are
printed. For persistent printing a count of -1 should be used.
"""
function print_margin(r::Writer)
    for seg in r.format.margin
        if seg.count == 0
            # Blank space case.
            print(r.format.buffer, ' '^seg.width)
        else
            # The normal case, where .count is reduced after each print.
            print(r.format.buffer, seg.text)
            seg.count > 0 && (seg.count -= 1)
        end
    end
end

function maybe_print_margin(r, node::Node)
    if isnull(node.first_child)
        push_margin!(r, "\n")
        print_margin(r)
        pop_margin!(r)
    end
    return nothing
end

"""
Literal printing of a of `parts`. Behaviour depends on when `.wrap` is active
at the moment, which is set in `Paragraph` rendering.
"""
function print_literal(r::Writer{Term}, parts...)
    # Ignore printing literals when there isn't much space, stops causing
    # stackoverflows and avoids printing badly wrapped lines when there's no
    # use printing them.
    available_columns(r) < 5 && return

    if r.format.wrap < 0
        # We just print everything normally here, allowing for the possibility
        # of bad automatic line wrapping by the terminal.
        for part in parts
            print(r.format.buffer, part)
        end
    else
        # We're in a `Paragraph` and so want nice line wrapping.
        for part in parts
            print_literal_part(r, part)
        end
    end
end

function print_literal_part(r::Writer{Term}, lit::AbstractString, rec=0)
    width = Base.Unicode.textwidth(lit)
    space = (available_columns(r) - r.format.wrap) + ispunct(get(lit, 1, '\0'))
    if width < space
        print(r.format.buffer, lit)
        r.format.wrap += width
    else
        index = findprev(c -> c in " -–—", lit, space)
        index = index === nothing ? (rec > 0 ? space : 0) : index
        head = SubString(lit, 1, thisind(lit, index))
        tail = SubString(lit, nextind(lit, index))

        print(r.format.buffer, rstrip(head), "\n")

        print_margin(r)
        r.format.wrap = 0

        print_literal_part(r, lstrip(tail), rec+1)
    end
end
print_literal_part(r::Writer{Term}, c::Crayon) = print(r.format.buffer, c)

# Rendering to terminal.

function write_term(::Document, render, node, enter)
    if enter
        push_margin!(render, LEFT_MARGIN, crayon"")
    else
        pop_margin!(render)
    end
end

function write_term(::Text, render, node, enter)
    print_literal(render, replace(node.literal, r"\s+" => ' '))
end

write_term(::Backslash, w, node, ent) = nothing

function write_term(::SoftBreak, render, node, enter)
    print_literal(render, " ")
end

function write_term(::LineBreak, render, node, enter)
    print(render.format.buffer, "\n")
    print_margin(render)
    render.format.wrap = render.format.wrap < 0 ? -1 : 0
end

function write_term(::Code, render, node, enter)
    style = crayon"cyan"
    print_literal(render, style)
    push_inline!(render, style)
    print_literal(render, node.literal)
    pop_inline!(render)
    print_literal(render, inv(style))
end

function write_term(::HtmlInline, render, node, enter)
    style = crayon"dark_gray"
    print_literal(render, style)
    push_inline!(render, style)
    print_literal(render, node.literal)
    pop_inline!(render)
    print_literal(render, inv(style))
end

function write_term(::Link, render, node, enter)
    style = crayon"blue underline"
    if enter
        print_literal(render, style)
        push_inline!(render, style)
    else
        pop_inline!(render)
        print_literal(render, inv(style))
    end
end

function write_term(::Image, render, node, enter)
    style = crayon"green"
    if enter
        print_literal(render, style)
        push_inline!(render, style)
    else
        pop_inline!(render)
        print_literal(render, inv(style))
    end
end

function write_term(::Emph, render, node, enter)
    style = crayon"italics"
    if enter
        print_literal(render, style)
        push_inline!(render, style)
    else
        pop_inline!(render)
        print_literal(render, inv(style))
    end
end

function write_term(::Strong, render, node, enter)
    style = crayon"bold"
    if enter
        print_literal(render, style)
        push_inline!(render, style)
    else
        pop_inline!(render)
        print_literal(render, inv(style))
    end
end

function write_term(::Paragraph, render, node, enter)
    if enter
        render.format.wrap = 0
        print_margin(render)
    else
        render.format.wrap = -1
        print_literal(render, "\n")
        if !isnull(node.nxt)
            print_margin(render)
            print_literal(render, "\n")
        end
    end
end

function write_term(heading::Heading, render, node, enter)
    if enter
        print_margin(render)
        style = crayon"blue bold"
        print_literal(render, style, "#"^heading.level, inv(style), " ")
    else
        print_literal(render, "\n")
        if !isnull(node.nxt)
            print_margin(render)
            print_literal(render, "\n")
        end
    end
end

function write_term(::BlockQuote, render, node, enter)
    if enter
        push_margin!(render, "│", crayon"bold")
        push_margin!(render, " ", crayon"")
    else
        pop_margin!(render)
        maybe_print_margin(render, node)
        pop_margin!(render)
        if !isnull(node.nxt)
            print_margin(render)
            print_literal(render, "\n")
        end
    end
end

function write_term(list::List, render, node, enter)
    if enter
        render.format.list_depth += 1
        push!(render.format.list_item_number, list.list_data.start)
        push_margin!(render, " ", crayon"")
    else
        render.format.list_depth -= 1
        pop!(render.format.list_item_number)
        pop_margin!(render)
        if !isnull(node.nxt)
            print_margin(render)
            print_literal(render, "\n")
        end
    end
end

function write_term(item::Item, render, node, enter)
    if enter
        if item.list_data.type === :ordered
            number = string(render.format.list_item_number[end], ". ")
            render.format.list_item_number[end] += 1
            push_margin!(render, 1, number, crayon"")
        else
            #              ●         ○         ▶         ▷         ■         □
            bullets = ['\u25CF', '\u25CB', '\u25B6', '\u25B7', '\u25A0', '\u25A1']
            bullet = bullets[min(render.format.list_depth, length(bullets))]
            push_margin!(render, 1, "$bullet ", crayon"")
        end
    else
        maybe_print_margin(render, node)
        pop_margin!(render)
        if !isnull(node.nxt)
            print_margin(render)
            print_literal(render, "\n")
        end
    end
end

function write_term(::ThematicBreak, render, node, enter)
    print_margin(render)
    style = crayon"dark_gray"
    stars = " § "
    padding = '═'^padding_between(available_columns(render), length(stars))
    print_literal(render, style, padding, stars, padding, inv(style), "\n")
    if !isnull(node.nxt)
        print_margin(render)
        print_literal(render, "\n")
    end
end

function write_term(::CodeBlock, render, node, enter)
    pipe = crayon"cyan"
    style = crayon"dark_gray"
    for line in eachline(IOBuffer(_syntax_highlighter(render, MIME("text/plain"), node)))
        print_margin(render)
        print_literal(render, "  ", pipe, "│", inv(pipe), " ")
        print_literal(render, style, line, inv(style), "\n")
    end
    if !isnull(node.nxt)
        print_margin(render)
        print_literal(render, "\n")
    end
end

function write_term(::HtmlBlock, render, node, enter)
    style = crayon"dark_gray"
    for line in eachline(IOBuffer(node.literal))
        print_margin(render)
        print_literal(render, style, line, inv(style), "\n")
    end
    if !isnull(node.nxt)
        print_margin(render)
        print_literal(render, "\n")
    end
end
