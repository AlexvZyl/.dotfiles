# [[fg:]<col>] [bg:<col>] ([[!]properties], ...)

macro crayon_str(str::String)
    _reset         = ANSIStyle()
    _bold          = ANSIStyle()
    _faint         = ANSIStyle()
    _italics       = ANSIStyle()
    _underline     = ANSIStyle()
    _blink         = ANSIStyle()
    _negative      = ANSIStyle()
    _conceal       = ANSIStyle()
    _strikethrough = ANSIStyle()

    fgcol = ANSIColor()
    bgcol = ANSIColor()

    for word in split(str, " ")
        length(word) == 0 && continue
        token = word
        enabled = true
        parse_state = :style

        if word[1] == '!'
            enabled = false
            token = word[2:end]
            @goto doparse
        end

        if ':' in word
            ws = split(word, ':')
            if length(ws) != 2
                @goto parse_err
            end
            val, token = ws
            if val == "fg"
                parse_state = :fg_color
            elseif val == "bg"
                parse_state = :bg_color
            else
                @goto parse_err
            end
            @goto doparse
            @label parse_err
            return :(throw(ArgumentError("should have the format [fg/bg]:color")))
        end

        @label doparse
        if parse_state == :fg_color || parse_state == :bg_color
            color = _parse_color_string(token)
            if parse_state == :fg_color
                fgcol = color
            else
                bgcol = color
            end
        elseif parse_state == :style
            if token == "reset"
                _reset = ANSIStyle(enabled)
            elseif token == "bold"
                _bold = ANSIStyle(enabled)
            elseif token == "faint"
                _faint = ANSIStyle(enabled)
            elseif token == "italics"
                _italics = ANSIStyle(enabled)
            elseif token == "underline"
                _underline = ANSIStyle(enabled)
            elseif token == "blink"
                _blink = ANSIStyle(enabled)
            elseif token == "negative"
                _negative = ANSIStyle(enabled)
            elseif token == "conceal"
                _conceal = ANSIStyle(enabled)
            elseif token == "strikethrough"
                _strikethrough = ANSIStyle(enabled)
            else
                fgcol = _parse_color_string(token)
            end
        end
    end

    return Crayon(
        fgcol,
        bgcol,
        _reset,
        _bold,
        _faint,
        _italics,
        _underline,
        _blink,
        _negative,
        _conceal,
        _strikethrough,
    )
end

function _parse_color_string(token::AbstractString)
    if length(token) >= 6
        tok_hex = token
        startswith(token, "#") && (tok_hex = token[2:end])
        !startswith(token, "0x") && (tok_hex = "0x" * tok_hex)
        nhex = tryparse(UInt32, tok_hex)
        nhex !== nothing && return _parse_color(nhex)
    end

    nint = tryparse(Int, token)
    nint !== nothing && return _parse_color(nint)
    reg = r"\(([0-9]*),([0-9]*),([0-9]*)\)"
    m = match(reg, token)
    if m !== nothing
        r, g, b = m.captures
        return _parse_color(parse.(Int, (r, g, b)))
    end

    if Symbol(token) in keys(COLORS)
        return _parse_color(Symbol(token))
    end

    throw(ArgumentError("could not parse $token as a color"))
end
