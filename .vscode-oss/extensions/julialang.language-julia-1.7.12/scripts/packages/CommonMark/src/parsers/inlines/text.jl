struct SoftBreak <: AbstractInline end
struct LineBreak <: AbstractInline end

function parse_string(parser::InlineParser, block::Node)
    start = position(parser)
    while true
        char = trypeek(parser, Char, '\0')
        if char === '\0' || haskey(parser.inline_parsers, char)
            # Stop scanning once we've hit a trigger character.
            break
        end
        read(parser, Char)
    end
    start === position(parser) && return false
    append_child(block, text(String(bytes(parser, start, position(parser)-1))))
    return true
end

struct TextRule end
inline_rule(::TextRule) = Rule(parse_string, 1, "")

function parse_newline(parser::InlineParser, block::Node)
    @assert read(parser, Char) === '\n'
    lastc = block.last_child
    if !isnull(lastc) && lastc.t isa Text && endswith(lastc.literal, ' ')
        child = Node(endswith(lastc.literal, "  ") ? LineBreak() : SoftBreak())
        lastc.literal = rstrip(lastc.literal)
        append_child(block, child)
    else
        append_child(block, Node(SoftBreak()))
    end
    # Gobble leading spaces in next line.
    consume(parser, match(reInitialSpace, parser))
    return true
end

struct NewlineRule end
inline_rule(::NewlineRule) = Rule(parse_newline, 1, "\n")

struct TypographyRule
    double_quotes::Bool
    single_quotes::Bool
    ellipses::Bool
    dashes::Bool

    function TypographyRule(; kwargs...)
        return new(
            get(kwargs, :double_quotes, true),
            get(kwargs, :single_quotes, true),
            get(kwargs, :ellipses, true),
            get(kwargs, :dashes, true),
        )
    end
end

function inline_rule(tr::TypographyRule)
    return (
        tr.double_quotes ? Rule(parse_double_quote, 1, "\"") : nothing,
        tr.single_quotes ? Rule(parse_single_quote, 1, "'")  : nothing,
        tr.ellipses      ? Rule(parse_ellipsis,     1, ".")  : nothing,
        tr.dashes        ? Rule(parse_dashes,       1, "-")  : nothing
    )
end

function inline_modifier(tr::TypographyRule)
    return (tr.double_quotes || tr.single_quotes) ? Rule(process_emphasis, 1) : nothing
end

parse_single_quote(parser, block) = handle_delim(parser, ''', block)
parse_double_quote(parser, block) = handle_delim(parser, '"', block)

function parse_ellipsis(parser::InlineParser, block::Node)
    m = consume(parser, match(r"^\.{3}", parser))
    return m === nothing ? false : (append_child(block, text("\u2026")); true)
end

function parse_dashes(parser::InlineParser, block::Node)
    m = consume(parser, match(r"^-+", parser))
    append_child(block, text(smart_dashes(m.match)))
    return true
end

function smart_dashes(chars::AbstractString)
    en_count, em_count, n = 0, 0, length(chars)
    if n === 1
        return chars
    elseif n % 3 === 0
        # If divisible by 3, use all em dashes.
        em_count = n ÷ 3
    elseif n % 2 === 0
        # If divisble by 2, use all en dashes.
        en_count = n ÷ 2
    elseif n % 3 === 2
        # If 2 extra dashes, use en-dash for last 2; em-dashes for rest.
        en_count, em_count = 1, (n - 2) ÷ 3
    else
        # Use en-dashes for last 4 hyphens; em-dashes for rest.
        en_count, em_count = 2, (n - 4) ÷ 3
    end
    return '\u2014'^em_count * '\u2013'^en_count
end

struct Text <: AbstractInline end

function text(s::AbstractString)
    node = Node(Text())
    node.literal = s
    return node
end
text(c::AbstractChar) = text(string(c))
