function parse_backslash(parser::InlineParser, block::Node)
    @assert read(parser, Char) === '\\'
    char = trypeek(parser, Char)
    if char === '\n'
        read(parser, Char)
        node = Node(LineBreak())
        append_child(block, Node(Backslash()))
        append_child(block, node)
    elseif char in ESCAPABLE
        read(parser, Char)
        append_child(block, Node(Backslash()))
        append_child(block, text(char))
    else
        append_child(block, text('\\'))
    end
    return true
end

struct Backslash <: AbstractInline end

struct BackslashEscapeRule end
inline_rule(::BackslashEscapeRule) = Rule(parse_backslash, 1, "\\")
