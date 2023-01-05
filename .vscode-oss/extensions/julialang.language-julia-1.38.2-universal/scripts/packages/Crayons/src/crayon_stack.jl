# Type for pushing and popping text states
struct CrayonStack
    incremental::Bool
    crayons::Vector{Crayon}
end

Base.print(io::IO, cs::CrayonStack) = print(io, cs.crayons[end])

function CrayonStack(; incremental::Bool = false)
    CrayonStack(incremental, [Crayon(ANSIColor(0x9, COLORS_16, !incremental),
                                     ANSIColor(0x9, COLORS_16, !incremental),
                                     ANSIStyle(false, !incremental),
                                     ANSIStyle(false, !incremental),
                                     ANSIStyle(false, !incremental),
                                     ANSIStyle(false, !incremental),
                                     ANSIStyle(false, !incremental),
                                     ANSIStyle(false, !incremental),
                                     ANSIStyle(false, !incremental),
                                     ANSIStyle(false, !incremental),
                                     ANSIStyle(false, !incremental))])
end

# Checks if equal disregarding active or not
_equal(a::ANSIColor, b::ANSIColor) = a.r == b.r && a.g == b.g && a.b == b.b && a.style == b.style
_equal(a::ANSIStyle, b::ANSIStyle) = a.on == b.on


# Currently we have the crayon a on the stack.
# We now want to push the crayon b.
# If in incremental mode we compute the changes needed to achive the state of b.
function _incremental_add(a::ANSIColor, b::ANSIColor, incremental::Bool)
    if b.active
        return ANSIColor(b.r, b.g, b.b, b.style, !_equal(a, b) || !incremental)
    else
        return ANSIColor(a.r, a.g, a.b, a.style, !incremental)
    end
end

# Similar to above
_incremental_add(a::ANSIStyle, b::ANSIStyle, incremental::Bool) = b.active ? ANSIStyle(b.on, !_equal(a, b) || !incremental) : ANSIStyle(a.on, !incremental)

# Have a, going to b
# State should be exactly as b!
# However, we only want to activate those that are needed, that is
# those that are active in a AND are different from b
_incremental_sub(a::ANSIColor, b::ANSIColor, incremental::Bool) = ANSIColor(b.r, b.g, b.b, b.style, !_equal(a, b) || !incremental)
_incremental_sub(a::ANSIStyle, b::ANSIStyle, incremental::Bool) = ANSIStyle(b.on, !_equal(a, b) || !incremental)


function Base.push!(cs::CrayonStack, c::Crayon)
    pc = cs.crayons[end]
    push!(cs.crayons, Crayon(
        _incremental_add(pc.fg           , c.fg           , cs.incremental),
        _incremental_add(pc.bg           , c.bg           , cs.incremental),
        _incremental_add(pc.reset        , c.reset        , cs.incremental),
        _incremental_add(pc.bold         , c.bold         , cs.incremental),
        _incremental_add(pc.faint        , c.faint        , cs.incremental),
        _incremental_add(pc.italics      , c.italics      , cs.incremental),
        _incremental_add(pc.underline    , c.underline    , cs.incremental),
        _incremental_add(pc.blink        , c.blink        , cs.incremental),
        _incremental_add(pc.negative     , c.negative     , cs.incremental),
        _incremental_add(pc.conceal      , c.conceal      , cs.incremental),
        _incremental_add(pc.strikethrough, c.strikethrough, cs.incremental)))
    return cs
end

function Base.pop!(cs::CrayonStack)
    length(cs.crayons) == 1 && throw(ArgumentError("no more Crayons left in stack"))

    c = pop!(cs.crayons)
    pc = cs.crayons[end]
    if length(cs.crayons) == 1
        pc = Crayon(ANSIColor(0x9, COLORS_16, true),
                    ANSIColor(0x9, COLORS_16, true),
                    ANSIStyle(false, true),
                    ANSIStyle(false, true),
                    ANSIStyle(false, true),
                    ANSIStyle(false, true),
                    ANSIStyle(false, true),
                    ANSIStyle(false, true),
                    ANSIStyle(false, true),
                    ANSIStyle(false, true),
                    ANSIStyle(false, true))
    end
    cs.crayons[end] = Crayon(
        _incremental_sub(c.fg           , pc.fg           , cs.incremental),
        _incremental_sub(c.bg           , pc.bg           , cs.incremental),
        _incremental_sub(c.reset        , pc.reset        , cs.incremental),
        _incremental_sub(c.bold         , pc.bold         , cs.incremental),
        _incremental_sub(c.faint        , pc.faint        , cs.incremental),
        _incremental_sub(c.italics      , pc.italics      , cs.incremental),
        _incremental_sub(c.underline    , pc.underline    , cs.incremental),
        _incremental_sub(c.blink        , pc.blink        , cs.incremental),
        _incremental_sub(c.negative     , pc.negative     , cs.incremental),
        _incremental_sub(c.conceal      , pc.conceal      , cs.incremental),
        _incremental_sub(c.strikethrough, pc.strikethrough, cs.incremental))
    # Return the currently active crayon so we can use print(pop!(crayonstack), "bla")
    return cs
end
