struct Paragraph <: AbstractBlock end

is_container(::Paragraph) = true

accepts_lines(::Paragraph) = true

continue_(::Paragraph, parser::Parser, ::Node) = parser.blank ? 1 : 0

function finalize(::Paragraph, p::Parser, block::Node)
    has_reference_defs = false
    # Try parsing the beginning as link reference definitions.
    while get(block.literal, 1, nothing) === '['
        pos = parse_reference(p.inline_parser, block.literal, p.refmap)
        pos == 0 && break
        block.literal = block.literal[pos+1:end]
        has_reference_defs = true
    end
    if has_reference_defs && is_blank(block.literal)
        unlink(block)
    end
    return nothing
end

can_contain(::Paragraph, t) = false
