mutable struct Link <: AbstractInline
    destination::String
    title::String
    Link() = new("", "")
end

is_container(::Link) = true

mutable struct Image <: AbstractInline
    destination::String
    title::String
    Image() = new("", "")
end

is_container(::Image) = true

chomp_ws(parser::InlineParser) = (consume(parser, match(reSpnl, parser)); true)

function parse_link_title(parser::InlineParser)
    title = consume(parser, match(reLinkTitle, parser))
    title === nothing && return nothing
    # Chop off quotes from title and unescape.
    return unescape_string(chop(title.match; head=1, tail=1))
end

function parse_link_destination(parser::InlineParser)
    res = consume(parser, match(reLinkDestinationBraces, parser))
    if res === nothing
        trypeek(parser, Char) === '<' && return nothing
        savepos = position(parser)
        openparens = 0
        c = trypeek(parser, Char)
        while true
            c = trypeek(parser, Char)
            if c === nothing
                break
            end
            if c == '\\' && trynext(parser, Char) in ESCAPABLE
                @assert read(parser, Char) === '\\'
                if trypeek(parser, Char) !== nothing
                    read(parser, Char)
                end
            elseif c == '('
                @assert read(parser, Char) === '('
                openparens += 1
            elseif c == ')'
                if openparens < 1
                    break
                else
                    @assert read(parser, Char) === ')'
                    openparens -= 1
                end
            elseif c in WHITESPACECHAR
                break
            else
                read(parser, Char)
            end
        end
        if position(parser) === savepos && c !== ')'
            return nothing
        end
        res = String(bytes(parser, savepos, position(parser) - 1))
        return normalize_uri(unescape_string(res))
    else
        # Chop off surrounding <..>.
        return normalize_uri(unescape_string(chop(res.match; head=1, tail=1)))
    end
end

function parse_link_label(parser::InlineParser)
    m = consume(parser, match(reLinkLabel, parser))
    return (m === nothing || length(m.match) ≥ 1000) ? 0 : ncodeunits(m.match)
end

function parse_open_bracket(parser::InlineParser, block::Node)
    startpos = position(parser)
    @assert read(parser, Char) === '['
    node = text("[")
    append_child(block, node)
    # Add entry to stack for this opener.
    add_bracket!(parser, node, startpos, false)
    return true
end

function parse_bang(parser::InlineParser, block::Node)
    startpos = position(parser)
    @assert read(parser, Char) === '!'
    if trypeek(parser, Char) === '['
        @assert read(parser, Char) === '['
        node = text("![")
        append_child(block, node)
        # Add entry to stack for this openeer.
        add_bracket!(parser, node, startpos + 1, true)
    else
        append_child(block, text("!"))
    end
    return true
end

function parse_close_bracket(parser::InlineParser, block::Node)
    title = nothing
    matched = false
    @assert read(parser, Char) === ']'
    startpos = position(parser)
    # Get last [ or ![.
    opener = parser.brackets
    if opener === nothing
        # No matched opener, just return a literal.
        append_child(block, text("]"))
        return true
    end
    if !opener.active
        # No matched opener, just return a literal.
        append_child(block, text("]"))
        # Take opener off brackets stack.
        remove_bracket!(parser)
        return true
    end
    # If we got here, opener is a potential opener.
    is_image = opener.image
    # Check to see if we have a link/image.
    savepos = position(parser)
    # Inline link?
    if trypeek(parser, Char, '\0') === '('
        @assert read(parser, Char) === '('
        chomp_ws(parser)
        dest = parse_link_destination(parser)
        if dest !== nothing && chomp_ws(parser)
            # Make sure there's a space before the title.
            if prev(parser, Char) in WHITESPACECHAR
                title = parse_link_title(parser)
            end
            if chomp_ws(parser) && trypeek(parser, Char, '\0') === ')'
                @assert read(parser, Char) === ')'
                matched = true
            end
        else
            seek(parser, savepos)
        end
    end
    if !matched
        # Next, see if there's a link label.
        beforelabel = position(parser)
        n = parse_link_label(parser)
        reflabel = ""
        if n > 2
            reflabel = String(bytes(parser, beforelabel, beforelabel + n - 1))
        elseif !opener.bracket_after
            # Empty or missing second label means to use the first label as the
            # reference. The reference must not contain a bracket. If we know
            # there's a bracket, we don't even bother checking it.
            reflabel = String(bytes(parser, opener.index, startpos - 1))
        end
        if n == 0
            # If shortcut reference link, rewind before spaces we skipped.
            seek(parser, savepos)
        end
        if !isempty(reflabel)
            # Lookup rawlabel in refmap.
            link = get(parser.refmap, normalize_reference(reflabel), nothing)
            if link !== nothing
                dest, title = link
                matched = true
            end
        end
    end
    if matched
        node = Node(is_image ? Image() : Link())
        node.t.destination = dest
        node.t.title = title === nothing ? "" : title
        tmp = opener.node.nxt
        while !isnull(tmp)
            nxt = tmp.nxt
            unlink(tmp)
            append_child(node, tmp)
            tmp = nxt
        end
        append_child(block, node)
        process_emphasis(parser, opener.previousDelimiter)
        remove_bracket!(parser)
        unlink(opener.node)
        # We remove this bracket and process_emphasis will remove later
        # delimiters. Now, for a link, we also deactivate earlier link openers.
        # (no links in links).
        if !is_image
            opener = parser.brackets
            while opener !== nothing
                if !opener.image
                    # Deactivate this opener.
                    opener.active = false
                end
                opener = opener.previous
            end
        end
        return true
    else
        # No match remove this opener from stack.
        remove_bracket!(parser)
        seek(parser, startpos)
        append_child(block, text("]"))
        return true
    end
end

function add_bracket!(p::InlineParser, node::Node, index::Integer, img::Bool)
    if p.brackets !== nothing
        p.brackets.bracket_after = true
    end
    p.brackets = Bracket(node, p.brackets, p.delimiters, index, img, true, false)
end

remove_bracket!(p::InlineParser) = p.brackets = p.brackets.previous

function parse_reference(parser::InlineParser, s::AbstractString, refmap::Dict)
    parser.buf = s
    seek(parser, 1)
    startpos = position(parser)

    # Label.
    match_chars = parse_link_label(parser)
    match_chars in (0, 2) && return 0
    rawlabel = String(bytes(parser, 1, match_chars))

    # Colon.
    trypeek(parser, Char) === ':' || (seek(parser, startpos); return 0)
    @assert read(parser, Char) === ':'

    # Link URL.
    chomp_ws(parser)
    dest = parse_link_destination(parser)
    dest === nothing && (seek(parser, startpos); return 0)

    beforetitle = position(parser)
    chomp_ws(parser)
    title = nothing
    if position(parser) !== beforetitle
        title = parse_link_title(parser)
    end
    if title === nothing
        title = ""
        # Rewind before spaces.
        seek(parser, beforetitle)
    end

    # Make sure we're at line end.
    at_line_end = true
    if consume(parser, match(reSpaceAtEndOfLine, parser)) === nothing
        if title == ""
            at_line_end = false
        else
            # The potential title we found is not at the line end, but it could
            # still be a legal link reference if we discard the title.
            title == ""
            # Rewind to before spaces.
            seek(parser, beforetitle)
            # Or instead check if the link URL is at the line end.
            at_line_end = consume(parser, match(reSpaceAtEndOfLine, parser)) !== nothing
        end
    end

    at_line_end || (seek(parser, startpos); return 0)

    normlabel = normalize_reference(rawlabel)
    normlabel == "[]" && (seek(parser, startpos); return 0)

    haskey(refmap, normlabel) || (refmap[normlabel] = (dest, title))
    parser.refmap = refmap
    return position(parser) - startpos
end

struct LinkRule end
inline_rule(::LinkRule) = (Rule(parse_open_bracket, 1, "["), Rule(parse_close_bracket, 1, "]"))

struct ImageRule end
inline_rule(::ImageRule) = (Rule(parse_bang, 1, "!"), inline_rule(LinkRule())...)
