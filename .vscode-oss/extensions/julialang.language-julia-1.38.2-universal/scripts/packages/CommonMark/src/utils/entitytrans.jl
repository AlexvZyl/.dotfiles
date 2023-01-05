const ENTITY_DATA = JSON.Parser.parsefile(joinpath(@__DIR__, "entities.json"))

function HTMLunescape(s)
    @assert startswith(s, '&')
    if startswith(s, "&#")
        num = if startswith(s, "&#X") || startswith(s, "&#x")
            Base.parse(UInt32, s[4:end-1]; base=16)
        else
            Base.parse(UInt32, s[3:end-1])
        end
        num == 0 && return "\uFFFD"
        try
            return string(Char(num))
        catch err
            err isa Base.CodePointError || rethrow(err)
            return "\uFFFD"
        end
    else
        haskey(ENTITY_DATA, s) || return s
        return ENTITY_DATA[s]["characters"]
    end
end
