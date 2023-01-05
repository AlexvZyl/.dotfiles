struct Code <: AbstractInline end

function parse_backticks(parser::InlineParser, block::Node)
    # Any length sequence of backticks is a valid code opener.
    ticks = consume(parser, match(reTicksHere, parser))
    ticks === nothing && return false
    after_opener, count = position(parser), length(ticks.match)
    while true
        # Scan through the string for a matching backtick sequence.
        matched = consume(parser, match(reTicks, parser))
        matched === nothing && break
        if length(matched.match) === count
            before_closer = position(parser) - count - 1
            raw = String(bytes(parser, after_opener, before_closer))
            node = Node(Code())
            node.literal = normalize_inline_code(raw)
            append_child(block, node)
            return true
        end
    end
    # If we got here, we didn't match a closing backtick sequence.
    seek(parser, after_opener)
    append_child(block, text(ticks.match))
    return true
end

# Conforming inline code normalization:
#
#   - replace all newline characters with spaces
#   - when the string is not just space characters strip exactly
#     one leading and trailing space characters.
function normalize_inline_code(str::AbstractString)
    str = replace(str, '\n' => ' ')
    all_space = all(c -> c === ' ', str)
    if !all_space && occursin(r"^ .+ $", str)
        str = chop(str; head=1, tail=1)
    end
    return str
end

struct InlineCodeRule end
inline_rule(::InlineCodeRule) = Rule(parse_backticks, 1, "`")
