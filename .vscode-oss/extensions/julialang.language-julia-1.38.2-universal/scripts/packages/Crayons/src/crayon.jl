const FORCE_COLOR = Ref(false)
const FORCE_256_COLORS = Ref(false)
const FORCE_SYSTEM_COLORS = Ref(false)

force_color(b::Bool)         = FORCE_COLOR[]         = b
force_256_colors(b::Bool)    = FORCE_256_COLORS[]    = b
force_system_colors(b::Bool) = FORCE_SYSTEM_COLORS[] = b

_force_color()         = FORCE_COLOR[]         || haskey(ENV, "FORCE_COLOR")
_force_256_colors()    = FORCE_256_COLORS[]    || haskey(ENV, "FORCE_256_COLORS")
_force_system_colors() = FORCE_SYSTEM_COLORS[] || haskey(ENV, "FORCE_SYSTEM_COLORS")

const CSI = "\e["
const ESCAPED_CSI = "\\e["
const END_ANSI = "m"

# Add 30 to get fg ANSI
# Add 40 to get bg ANSI
const COLORS = Dict(
    :black         => 0,
    :red           => 1,
    :green         => 2,
    :yellow        => 3,
    :blue          => 4,
    :magenta       => 5,
    :cyan          => 6,
    :light_gray    => 7,
    :default       => 9,
    :dark_gray     => 60,
    :light_red     => 61,
    :light_green   => 62,
    :light_yellow  => 63,
    :light_blue    => 64,
    :light_magenta => 65,
    :light_cyan    => 66,
    :white         => 67
)

@enum(ColorMode,
RESET,
COLORS_16,
COLORS_256,
COLORS_24BIT)

struct ANSIColor
    r::UInt8 # [0-9, 60-69] for 16 colors, 0-255 for 256 colors
    g::UInt8
    b::UInt8
    style::ColorMode
    active::Bool
end

ANSIColor(r, g, b, style::ColorMode=COLORS_16, active=true) = ANSIColor(UInt8(r), UInt8(g), UInt8(b), style, active)
ANSIColor() = ANSIColor(0x0, 0x0, 0x0, COLORS_16, false)
ANSIColor(val::Integer, style::ColorMode, active::Bool = true) = ANSIColor(UInt8(val), 0, 0, style, active)

red(x::ANSIColor) = x.r
green(x::ANSIColor) = x.g
blue(x::ANSIColor) = x.b
val(x::ANSIColor) = x.r

# The inverse sets the color to default.
# No point making active if color already is default
Base.inv(x::ANSIColor) = ANSIColor(0x9, 0x0, 0x0, COLORS_16, x.active && !(x.style == COLORS_16 && x.r == 9))

struct ANSIStyle
    on::Bool
    active::Bool
end

ANSIStyle() = ANSIStyle(false, false)
ANSIStyle(v::Bool) = ANSIStyle(v, true)

# The inverse always sets the thing to false
# No point in setting active if the style is off.
Base.inv(x::ANSIStyle) = ANSIStyle(false, x.active && x.on)

struct Crayon
    fg::ANSIColor
    bg::ANSIColor

    reset::ANSIStyle
    bold::ANSIStyle
    faint::ANSIStyle
    italics::ANSIStyle
    underline::ANSIStyle
    blink::ANSIStyle
    negative::ANSIStyle
    conceal::ANSIStyle
    strikethrough::ANSIStyle
end

anyactive(x::Crayon) = ((x.reset.active && x.reset.on) ||
                        x.fg.active    || x.bg.active       || x.bold.active      ||
                        x.faint.active || x.italics.active  || x.underline.active ||
                        x.blink.active || x.negative.active || x.conceal.active   || x.strikethrough.active)

Base.inv(c::Crayon) = Crayon(inv(c.fg), inv(c.bg), ANSIStyle(), # no point taking inverse of reset,
                             inv(c.bold), inv(c.faint), inv(c.italics), inv(c.underline),
                             inv(c.blink), inv(c.negative), inv(c.conceal), inv(c.strikethrough))

function _have_color()
    if isdefined(Base, :get_have_color)
        return Base.get_have_color()
    else
        Base.have_color
    end
end
function Base.print(io::IO, x::Crayon)
    if anyactive(x) && (_have_color() || _force_color())
        print(io, CSI)
        if (x.fg.style == COLORS_24BIT || x.bg.style == COLORS_24BIT)
            if _force_256_colors()
                x = to_256_colors(x)
            elseif _force_system_colors()
                x = to_system_colors(x)
            end
        end
        _print(io, x)
        print(io, END_ANSI)
    end
end

function Base.show(io::IO, x::Crayon)
    if anyactive(x)
        print(io, x)
        print(io, ESCAPED_CSI)
        _print(io, x)
        print(io, END_ANSI, CSI, "0", END_ANSI)
    end
end

_ishex(c::Char) = isdigit(c) || ('a' <= c <= 'f') || ('A' <= c <= 'F')

function _torgb(hex::UInt32)::NTuple{3, UInt8}
    (hex << 8 >> 24, hex << 16 >> 24, hex << 24 >> 24)
end

function _parse_color(c::Union{Integer,Symbol,NTuple{3,Integer},UInt32})
    ansicol = ANSIColor()
    if c != :nothing
        if isa(c, Symbol)
            ansicol = ANSIColor(COLORS[c], COLORS_16)
        elseif isa(c, UInt32)
            r, g, b = _torgb(c)
            ansicol = ANSIColor(r, g, b, COLORS_24BIT)
        elseif isa(c, Integer)
            ansicol = ANSIColor(c, COLORS_256)
        elseif isa(c, NTuple{3,Integer})
            ansicol = ANSIColor(c[1], c[2], c[3], COLORS_24BIT)
        else
            error("should not happen")
        end
    end
    return ansicol
end

function Crayon(;foreground::Union{Int,Symbol,NTuple{3,Integer},UInt32} = :nothing,
                 background::Union{Int,Symbol,NTuple{3,Integer},UInt32} = :nothing,
                 reset = :nothing,
                 bold = :nothing,
                 faint = :nothing,
                 italics = :nothing,
                 underline = :nothing,
                 blink = :nothing,
                 negative = :nothing,
                 conceal = :nothing,
                 strikethrough = :nothing)

    fgcol = _parse_color(foreground)
    bgcol = _parse_color(background)

    _reset         = ANSIStyle()
    _bold          = ANSIStyle()
    _faint         = ANSIStyle()
    _italics       = ANSIStyle()
    _underline     = ANSIStyle()
    _blink         = ANSIStyle()
    _negative      = ANSIStyle()
    _conceal       = ANSIStyle()
    _strikethrough = ANSIStyle()

    reset         != :nothing && (_reset         = ANSIStyle(reset))
    bold          != :nothing && (_bold          = ANSIStyle(bold))
    faint         != :nothing && (_faint         = ANSIStyle(faint))
    italics       != :nothing && (_italics       = ANSIStyle(italics))
    underline     != :nothing && (_underline     = ANSIStyle(underline))
    blink         != :nothing && (_blink         = ANSIStyle(blink))
    negative      != :nothing && (_negative      = ANSIStyle(negative))
    conceal       != :nothing && (_conceal       = ANSIStyle(conceal))
    strikethrough != :nothing && (_strikethrough = ANSIStyle(strikethrough))

    return Crayon(fgcol,
                  bgcol,
                  _reset,
                  _bold,
                  _faint,
                  _italics,
                  _underline,
                  _blink,
                  _negative,
                  _conceal,
                  _strikethrough)
end

# Prints the crayon without the inital and terminating ansi escape sequences
function _print(io::IO, c::Crayon)
    first_active = true
    if c.reset.active && c.reset.on
        first_active = false
        print(io, "0")
    end

    for (col, num) in ((c.fg, 30),
                       (c.bg, 40))
        if col.active
            !first_active && print(io, ";")
            first_active = false

            col.style == COLORS_16    && print(io, val(col) + num)
            col.style == COLORS_256   && print(io, num + 8, ";5;", val(col))
            col.style == COLORS_24BIT && print(io, num + 8, ";2;", red(col), ";", green(col), ";", blue(col))
        end
    end

    for (style, val) in ((c.bold, 1),
                         (c.faint, 2),
                         (c.italics, 3),
                         (c.underline, 4),
                         (c.blink, 5),
                         (c.negative, 7),
                         (c.conceal, 8),
                         (c.strikethrough, 9))

        if style.active
            !first_active && print(io, ";")
            first_active = false

            style.on && print(io, val)
            # Bold off is actually 22 so special case for val == 1
            !style.on && print(io, val == 1 ? val + 21 : val + 20)
        end
    end
    return nothing
end

function Base.merge(a::Crayon, b::Crayon)
    fg            = b.fg.active            ? b.fg            : a.fg
    bg            = b.bg.active            ? b.bg            : a.bg
    reset         = b.reset.active         ? b.reset         : a.reset
    bold          = b.bold.active          ? b.bold          : a.bold
    faint         = b.faint.active         ? b.faint         : a.faint
    italics       = b.italics.active       ? b.italics       : a.italics
    underline     = b.underline.active     ? b.underline     : a.underline
    blink         = b.blink.active         ? b.blink         : a.blink
    negative      = b.negative.active      ? b.negative      : a.negative
    conceal       = b.conceal.active       ? b.conceal       : a.conceal
    strikethrough = b.strikethrough.active ? b.strikethrough : a.strikethrough

    return Crayon(fg,
                  bg,
                  reset,
                  bold,
                  faint,
                  italics,
                  underline,
                  blink,
                  negative,
                  conceal,
                  strikethrough)
end

Base.:*(a::Crayon, b::Crayon) = merge(a, b)

function Base.merge(tok::Crayon, toks::Crayon...)
    for tok2 in toks
        tok = merge(tok, tok2)
    end
    return tok
end
