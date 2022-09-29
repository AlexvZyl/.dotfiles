struct BlockQuote <: AbstractBlock end

is_container(::BlockQuote) = true

accepts_lines(::BlockQuote) = false

function continue_(::BlockQuote, parser::Parser, container::Node)
    ln = parser.buf
    if !parser.indented && get(ln, parser.next_nonspace, nothing) == '>'
        advance_next_nonspace(parser)
        advance_offset(parser, 1, false)
        if is_space_or_tab(get(ln, parser.pos, nothing))
            advance_offset(parser, 1, true)
        end
    else
        return 1
    end
    return 0
end

finalize(::BlockQuote, ::Parser, ::Node) = nothing

can_contain(::BlockQuote, t) = !(t isa Item)

function block_quote(parser::Parser, container::Node)
    if !parser.indented && get(parser.buf, parser.next_nonspace, nothing) == '>'
        advance_next_nonspace(parser)
        advance_offset(parser, 1, false)
        # optional following space
        if is_space_or_tab(get(parser.buf, parser.pos, nothing))
            advance_offset(parser, 1, true)
        end
        close_unmatched_blocks(parser)
        add_child(parser, BlockQuote(), parser.next_nonspace)
        return 1
    end
    return 0
end

struct BlockQuoteRule end
block_rule(::BlockQuoteRule) = Rule(block_quote, 1, ">")
