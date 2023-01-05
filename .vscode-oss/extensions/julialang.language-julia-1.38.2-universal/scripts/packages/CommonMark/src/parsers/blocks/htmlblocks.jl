mutable struct HtmlBlock <: AbstractBlock
    html_block_type::Int
    HtmlBlock() = new(0)
end

accepts_lines(::HtmlBlock) = true

function continue_(::HtmlBlock, parser::Parser, container::Node)
    (parser.blank && container.t.html_block_type in 6:7) ? 1 : 0
end

function finalize(::HtmlBlock, parser::Parser, block::Node)
    block.literal = replace(block.literal, r"(\n *)+$" => "")
    return nothing
end

can_contain(::HtmlBlock, t) = false

function html_block(parser::Parser, container::Node)
    if !parser.indented && get(parser.buf, parser.next_nonspace, nothing) == '<'
        s = SubString(parser.buf, parser.next_nonspace)
        for (block_type, regex) in enumerate(reHtmlBlockOpen)
            if occursin(regex, s) && (block_type < 7 || !(container.t isa Paragraph))
                close_unmatched_blocks(parser)
                # Don't adjust parser.pos; spaces are part of HTML block.
                b = add_child(parser, HtmlBlock(), parser.pos)
                b.t.html_block_type = block_type
                return 2
            end
        end
    end
    return 0
end

struct HtmlBlockRule end
block_rule(::HtmlBlockRule) = Rule(html_block, 4, "<>")
