# Vendored from LanguageServer.jl
# TODO Can we move this into CSTParser, where it really should be? Problem is
function descend(x::EXPR, target::EXPR, offset=0)
    x == target && return (true, offset)
    for c in x
        if c == target
            return true, offset
        end

        found, o = descend(c, target, offset)
        if found
            return true, o
        end
        offset += c.fullspan
    end
    return false, offset
end

# Vendored from LanguageServer.jl
# TODO Can we move this into CSTParser, where it really should be? Problem is
# the part that is commented out right now
function get_file_loc(x::EXPR, offset=0, c=nothing)
    parent = x
    while CSTParser.parentof(parent) !== nothing
        parent = CSTParser.parentof(parent)
    end

    if parent === nothing
        return nothing, offset
    end

    _, offset = descend(parent, x)

    # TODO Unclear what this was for but don't want to take dep on StaticLint
    # if headof(parent) === :file && StaticLint.hasmeta(parent)
    #     return parent.meta.error, offset
    # end
    return nothing, offset
end
