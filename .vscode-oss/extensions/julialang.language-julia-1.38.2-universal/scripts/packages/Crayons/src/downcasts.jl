function to_256_colors(crayon::Crayon)
    fg = crayon.fg
    bg = crayon.bg
    crayon.fg.style == COLORS_24BIT && (fg = to_256_colors(crayon.fg))
    crayon.bg.style == COLORS_24BIT && (bg = to_256_colors(crayon.bg))
    return Crayon(
        fg,
        bg,
        crayon.reset,
        crayon.bold,
        crayon.faint,
        crayon.italics,
        crayon.underline,
        crayon.blink,
        crayon.negative,
        crayon.conceal,
        crayon.strikethrough,
    )
end

function to_256_colors(color::ANSIColor)
    @assert color.style == COLORS_24BIT
    r, g, b = color.r, color.g, color.b
    r24, g24, b24 = map(c->round(Int, c * 23 / 256), (r, g, b))
    if r24 == g24 == b24
        return ANSIColor(UInt8(232 + r24), COLORS_256, color.active)
    else
        r6, g6, b6 = map(c->round(Int, c * 5  / 256), (r, g, b))
        return ANSIColor(UInt8(16 + 36 * r6 + 6 * g6 + b6), COLORS_256, color.active)
    end
end

# 24bit -> 16 system colors
function to_system_colors(crayon::Crayon)
    fg = crayon.fg
    bg = crayon.bg
    crayon.fg.style == COLORS_24BIT && (fg = to_system_colors(crayon.fg))
    crayon.bg.style == COLORS_24BIT && (bg = to_system_colors(crayon.bg))
    return Crayon(
        fg,
        bg,
        crayon.reset,
        crayon.bold,
        crayon.faint,
        crayon.italics,
        crayon.underline,
        crayon.blink,
        crayon.negative,
        crayon.conceal,
        crayon.strikethrough,
    )
end

function compute_value(r, g, b)
    r′, g′, b′ = (r, g, b) ./ 255
    Cmax = max(r′, g′, b′)
    return Cmax * 100
    #=
    # This is not needed
    Cmin = min(r′, g′, b′)
    Δ = Cmax - Cmin
    H = begin
        if Cmax == r′
            60 * (((g′ - b′) / Δ) % 6)
        elseif Cmax == g′
            60 * ((b′ - r′) / Δ + 2)
        else
            60 * ((r′ - g′) / Δ + 4)
        end
    end

    S = Cmax == 0 ? 0 : (Δ / Cmax)
    V = Cmax
    return H * 360, S * 100, V * 100
    =#
end

function to_system_colors(color::ANSIColor)
    @assert color.style == COLORS_24BIT
    r, g, b = color.r, color.g, color.b
    value = compute_value(r, g, b)
    
    value = round(Int, value / 50)
    
    if (value == 0)
        ansi = 0
    else
        ansi = 
            ((round(Int, b / 255) << 2) |
             (round(Int, g / 255) << 1) |
              round(Int, r / 255))
        value == 2 && (ansi += 60)
    end
    return ANSIColor(UInt8(ansi), COLORS_16, color.active)
end
