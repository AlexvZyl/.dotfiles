function parse_autolink(parser::InlineParser, block::Node)
    m = consume(parser, match(reEmailAutolink, parser))
    if m !== nothing
        dest = chop(m.match; head=1, tail=1)
        node = Node(Link())
        node.t.destination = normalize_uri("mailto:$(dest)")
        node.t.title = ""
        append_child(node, text(dest))
        append_child(block, node)
        return true
    else
        m = consume(parser, match(reAutolink, parser))
        if m !== nothing
            dest = chop(m.match; head=1, tail=1)
            node = Node(Link())
            node.t.destination = normalize_uri(dest)
            node.t.title = ""
            append_child(node, text(dest))
            append_child(block, node)
            return true
        end
    end
    return false
end

struct AutolinkRule end
inline_rule(::AutolinkRule) = Rule(parse_autolink, 1, "<")
