#
# Inline math
#

struct Math <: AbstractInline end

function parse_inline_math_backticks(p::InlineParser, node::Node)
    ticks = match(reTicksHere, p)
    if ticks === nothing || isodd(length(ticks.match))
        return false
    end
    consume(p, ticks)
    after_opener, count = position(p), length(ticks.match)
    while true
        matched = consume(p, match(reTicks, p))
        matched === nothing && break
        if length(matched.match) === count
            before_closer = position(p) - count - 1
            raw = String(bytes(p, after_opener, before_closer))
            child = Node(Math())
            child.literal = strip(replace(raw, r"\s+" => ' '))
            append_child(node, child)
            return true
        end
    end
    # We didn't match an even length sequence.
    seek(p, after_opener)
    append_child(node, text(ticks.match))
    return true
end

#
# Display math
#

struct DisplayMath <: AbstractBlock end

function handle_fenced_math_block(node::Node, info, source)
    node.t = DisplayMath()
    node.literal = strip(source, '\n')
end

struct MathRule end
block_modifier(::MathRule) = Rule(1.5) do parser, node
    if node.t isa CodeBlock && node.t.info == "math"
        node.t = DisplayMath()
        node.literal = strip(node.literal, '\n')
    end
    return nothing
end
inline_rule(::MathRule) = Rule(parse_inline_math_backticks, 0, "`")

#
# Dollar math
#

struct DollarMathRule end

function parse_block_dollar_math(p::Parser, node::Node)
    if node.t isa Paragraph
        left = match(r"^(\$+)", node.literal)
        left === nothing && return nothing
        right = match(r"(\$+)$", rstrip(node.literal))
        right === nothing && return nothing
        if length(left[1]) == length(right[1]) == 2
            node.literal = strip(c -> isspace(c) || c === '$', node.literal)
            node.t = DisplayMath()
        end
    end
    return nothing
end

block_modifier(::DollarMathRule) = Rule(parse_block_dollar_math, 0)

const reDollarsHere = r"^\$+"
const reDollars = r"\$+"

function parse_inline_dollar_math(p::InlineParser, node::Node)
    dollars = match(reDollarsHere, p)
    if dollars === nothing || length(dollars.match) > 1
        return false
    end
    consume(p, dollars)
    after_opener, count = position(p), length(dollars.match)
    while true
        matched = consume(p, match(reDollars, p))
        matched === nothing && break
        if length(matched.match) === count
            before_closer = position(p) - count - 1
            raw = String(bytes(p, after_opener, before_closer))
            child = Node(Math())
            child.literal = strip(replace(raw, r"\s+" => ' '))
            append_child(node, child)
            return true
        end
    end
    # We didn't match a balanced closing sequence.
    seek(p, after_opener)
    append_child(node, text(dollars.match))
    return true
end

inline_rule(::DollarMathRule) = Rule(parse_inline_dollar_math, 0, "\$")

#
# Writers
#

function write_html(::Math, rend, node, enter)
    tag(rend, "span", attributes(rend, node, ["class" => "math tex"]))
    print(rend.buffer, "\\(", node.literal, "\\)")
    tag(rend, "/span")
end

function write_latex(::Math, rend, node, enter)
    print(rend.buffer, "\\(", node.literal, "\\)")
end

function write_term(::Math, rend, node, enter)
    style = crayon"magenta"
    push_inline!(rend, style)
    print_literal(rend, style, node.literal, inv(style))
    pop_inline!(rend)
end

function write_markdown(::Math, w, node, ent)
    num = foldl(eachmatch(r"`+", node.literal); init=0) do a, b
        max(a, length(b.match))
    end
    literal(w, "`"^(num == 2 ? 4 : 2))
    literal(w, node.literal)
    literal(w, "`"^(num == 2 ? 4 : 2))
end

function write_html(::DisplayMath, rend, node, enter)
    tag(rend, "div", attributes(rend, node, ["class" => "display-math tex"]))
    print(rend.buffer, "\\[", node.literal, "\\]")
    tag(rend, "/div")
end

function write_latex(::DisplayMath, rend, node, enter)
    println(rend.buffer, "\\begin{equation*}")
    println(rend.buffer, node.literal)
    println(rend.buffer, "\\end{equation*}")
end

function write_term(::DisplayMath, rend, node, enter)
    pipe = crayon"magenta"
    style = crayon"dark_gray"
    for line in eachline(IOBuffer(node.literal))
        print_margin(rend)
        print_literal(rend, "  ", pipe, "│", inv(pipe), " ")
        print_literal(rend, style, line, inv(style), "\n")
    end
    if !isnull(node.nxt)
        print_margin(rend)
        print_literal(rend, "\n")
    end
end

function write_markdown(::DisplayMath, w, node, ent)
    print_margin(w)
    literal(w, "```math\n")
    for line in eachline(IOBuffer(node.literal))
        print_margin(w)
        literal(w, line, "\n")
    end
    print_margin(w)
    literal(w, "```")
    cr(w)
    linebreak(w, node)
end
