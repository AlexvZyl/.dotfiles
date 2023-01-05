mutable struct CodeBlock <: AbstractBlock
    info::String
    is_fenced::Bool
    fence_char::Char
    fence_length::Int
    fence_offset::Int
    CodeBlock() = new("", false, '\0', 0, 0)
end

accepts_lines(::CodeBlock) = true

function continue_(::CodeBlock, parser::Parser, container::Node)
    ln = parser.buf
    indent = parser.indent
    if container.t.is_fenced
        match = indent <= 3 &&
            length(ln) >= parser.next_nonspace + 1 &&
            ln[parser.next_nonspace] == container.t.fence_char &&
            Base.match(reClosingCodeFence, SubString(ln, parser.next_nonspace))
        t = indent <= 3 && length(ln) >= parser.next_nonspace + 1 &&
            ln[parser.next_nonspace] == container.t.fence_char
        m = t ? Base.match(reClosingCodeFence, SubString(ln, parser.next_nonspace)) : nothing
        if m !== nothing && length(m.match) >= container.t.fence_length
            # closing fence - we're at end of line, so we can return
            finalize(parser, container, parser.line_number)
            return 2
        else
            # skip optional spaces of fence offset
            i = container.t.fence_offset
            while i > 0 && is_space_or_tab(get(ln, parser.pos, nothing))
                advance_offset(parser, 1, true)
                i -= 1
            end
        end
    else
        # indented
        if indent >= CODE_INDENT
            advance_offset(parser, CODE_INDENT, true)
        elseif parser.blank
            advance_next_nonspace(parser)
        else
            return 1
        end
    end
    return 0
end

# TODO: make more robust and finalize the 'spec'.
function split_info_line(str)
    line = rstrip(lstrip(str, '{'), '}')
    return split(line, ' ')
end

function finalize(::CodeBlock, parser::Parser, block::Node)
    if block.t.is_fenced
        # first line becomes info string
        first_line, rest = split(block.literal, '\n'; limit=2)
        info = unescape_string(strip(first_line))
        block.t.info = info
        block.literal = rest
    else
        # indented
        block.literal = replace(block.literal, r"(\n *)+$" => "\n")
    end
    return nothing
end

can_contain(t) = false

function fenced_code_block(parser::Parser, container::Node)
    if !parser.indented
        m = Base.match(reCodeFence, SubString(parser.buf, parser.next_nonspace))
        if m !== nothing
            fence_length = length(m.match)
            close_unmatched_blocks(parser)
            container = add_child(parser, CodeBlock(), parser.next_nonspace)
            container.t.is_fenced = true
            container.t.fence_length = fence_length
            container.t.fence_char = m.match[1]
            container.t.fence_offset = parser.indent
            advance_next_nonspace(parser)
            advance_offset(parser, fence_length, false)
            return 2
        end
    end
    return 0
end

struct FencedCodeBlockRule end
block_rule(::FencedCodeBlockRule) = Rule(fenced_code_block, 3, "`~")

function indented_code_block(parser::Parser, container::Node)
    if parser.indented && !(parser.tip.t isa Paragraph) && !parser.blank
        # indented code
        advance_offset(parser, CODE_INDENT, true)
        close_unmatched_blocks(parser)
        add_child(parser, CodeBlock(), parser.pos)
        return 2
    end
    return 0
end

struct IndentedCodeBlockRule end
block_rule(::IndentedCodeBlockRule) = Rule(indented_code_block, 8, "")
