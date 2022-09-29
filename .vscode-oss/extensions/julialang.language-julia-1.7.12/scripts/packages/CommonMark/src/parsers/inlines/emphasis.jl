struct Emph <: AbstractInline end

is_container(::Emph) = true

struct Strong <: AbstractInline end

is_container(::Strong) = true

parse_asterisk(parser, block) = handle_delim(parser, '*', block)
parse_underscore(parser, block) = handle_delim(parser, '_', block)

function scan_delims(parser::InlineParser, c::AbstractChar)
    numdelims = 0
    startpos = position(parser)

    c_before = tryprev(parser, Char, '\n')

    if c in (''', '"')
        numdelims += 1
        @assert read(parser, Char) === c
    else
        while trypeek(parser, Char) === c
            numdelims += 1
            @assert read(parser, Char) === c
        end
    end
    numdelims == 0 && return (0, false, false)

    c_after = trypeek(parser, Char, '\n')

    ws_after     = Base.Unicode.isspace(c_after)
    punct_after  = Base.Unicode.ispunct(c_after)
    ws_before    = Base.Unicode.isspace(c_before)
    punct_before = Base.Unicode.ispunct(c_before)

    left_flanking  = !ws_after  && (!punct_after  || ws_before || punct_before)
    right_flanking = !ws_before && (!punct_before || ws_after  || punct_after)
    can_open, can_close =
        if c == '_'
            (left_flanking  && (!right_flanking || punct_before)),
            (right_flanking && (!left_flanking  || punct_after))
        elseif c in (''', '"')
            (left_flanking && !right_flanking), right_flanking
        else
            left_flanking, right_flanking
        end

    seek(parser, startpos)
    return numdelims, can_open, can_close
end

function handle_delim(parser::InlineParser, cc::AbstractChar, block::Node)
    numdelims, can_open, can_close = scan_delims(parser, cc)
    numdelims === 0 && return false

    startpos = position(parser)

    seek(parser, position(parser) + numdelims) # `cc` is ASCII.
    contents = cc == ''' ? "\u2019" : cc == '"' ? "\u201C" : cc^numdelims

    node = text(contents)
    append_child(block, node)

    # Add entry to stack for this opener
    parser.delimiters = Delimiter(
        cc,
        numdelims,
        numdelims,
        node,
        parser.delimiters,
        nothing,
        can_open,
        can_close,
    )
    if parser.delimiters.previous !== nothing
        parser.delimiters.previous.next = parser.delimiters
    end
    return true
end

function remove_delimiter(parser::InlineParser, delim::Delimiter)
    if delim.previous !== nothing
        delim.previous.next = delim.next
    end
    if delim.next === nothing
        parser.delimiters = delim.previous # Top of stack.
    else
        delim.next.previous = delim.previous
    end
    return nothing
end

function remove_delimiters_between(bottom::Delimiter, top::Delimiter)
    if bottom.next !== top
        bottom.next = top
        top.previous = bottom
    end
    return nothing
end

function process_emphasis(parser::InlineParser, stack_bottom)
    openers_bottom = Dict{Char, Union{Nothing, Delimiter}}(
        '_' => stack_bottom,
        '*' => stack_bottom,
        ''' => stack_bottom,
        '"' => stack_bottom,
    )
    odd_match = false
    use_delims = 0

    # Find first closer above `stack_bottom`.
    closer = parser.delimiters
    while closer !== nothing && closer.previous !== stack_bottom
        closer = closer.previous
    end

    # Move forward, looking for closers, and handling each.
    while closer !== nothing
        if !closer.can_close
            closer = closer.next
        else
            # Found emphasis closer. Now look back for first matching opener.
            opener = closer.previous
            opener_found = false
            closercc = closer.cc
            while (opener !== nothing && opener !== stack_bottom && opener !== openers_bottom[closercc])
                odd_match = (closer.can_open || opener.can_close) && closer.origdelims % 3 != 0 && (opener.origdelims + closer.origdelims) % 3 == 0
                if opener.cc == closercc && opener.can_open && !odd_match
                    opener_found = true
                    break
                end
                opener = opener.previous
            end
            old_closer = closer

            if closercc in ('*', '_')
                if !opener_found
                    closer = closer.next
                else
                    # Calculate actual number of delimiters used from closer.
                    use_delims = (closer.numdelims ≥ 2 && opener.numdelims ≥ 2) ? 2 : 1

                    opener_inl = opener.node
                    closer_inl = closer.node

                    # Remove used delimiters from stack elements and inlines.
                    opener.numdelims -= use_delims
                    closer.numdelims -= use_delims
                    opener_inl.literal = opener_inl.literal[1:length(opener_inl.literal) - use_delims]
                    closer_inl.literal = closer_inl.literal[1:length(closer_inl.literal) - use_delims]

                    # Build contents for new Emph or Strong element.
                    emph = use_delims == 1 ? Node(Emph()) : Node(Strong())
                    emph.literal = closercc^use_delims

                    tmp = opener_inl.nxt
                    while !isnull(tmp) && tmp !== closer_inl
                        nxt = tmp.nxt
                        unlink(tmp)
                        append_child(emph, tmp)
                        tmp = nxt
                    end
                    insert_after(opener_inl, emph)

                    # Remove elts between opener and closer in delimiters stack.
                    remove_delimiters_between(opener, closer)

                    # If opener has 0 delims, remove it and the inline.
                    if opener.numdelims == 0
                        unlink(opener_inl)
                        remove_delimiter(parser, opener)
                    end

                    if closer.numdelims == 0
                        unlink(closer_inl)
                        tempstack = closer.next
                        remove_delimiter(parser, closer)
                        closer = tempstack
                    end
                end
            elseif closercc == '''
                closer.node.literal = "\u2019"
                opener_found && (opener.node.literal = "\u2018")
                closer = closer.next
            elseif closercc == '"'
                closer.node.literal = "\u201D"
                opener_found && (opener.node.literal = "\u201C")
                closer = closer.next
            end

            if !opener_found && !odd_match
                # Set lower bound for future searches for openers We don't do
                # this with odd_match because a ** that doesn't match an
                # earlier * might turn into an opener, and the * might be
                # matched by something else.
                openers_bottom[closercc] = old_closer.previous
                # We can remove a closer that can't be an opener, once we've
                # seen there's no matching opener.
                old_closer.can_open || remove_delimiter(parser, old_closer)
            end
        end
    end
    # Remove all delimiters
    while parser.delimiters !== nothing && parser.delimiters !== stack_bottom
        remove_delimiter(parser, parser.delimiters)
    end
end
process_emphasis(parser::InlineParser, ::Node) = process_emphasis(parser, nothing)

struct AsteriskEmphasisRule end
inline_rule(::AsteriskEmphasisRule) = Rule(parse_asterisk, 1, "*")
inline_modifier(::AsteriskEmphasisRule) = Rule(process_emphasis, 1)

struct UnderscoreEmphasisRule end
inline_rule(::UnderscoreEmphasisRule) = Rule(parse_underscore, 1, "_")
inline_modifier(::UnderscoreEmphasisRule) = Rule(process_emphasis, 1)
