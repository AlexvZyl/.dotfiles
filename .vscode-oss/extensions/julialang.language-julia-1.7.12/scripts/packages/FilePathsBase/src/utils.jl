# Mostly copied from https://github.com/IainNZ/Humanize.jl/blob/master/src/Humanize.jl#L27
function _datasize(bytes::Number)
    base = 1024.0
    nbytes = float(bytes)
    unit = base
    suffix = first(DATA_SUFFIX)

    for (i, s) in enumerate(DATA_SUFFIX)
        unit = base ^ i

        if nbytes < unit
            suffix = s
            break
        end
    end

    return @sprintf("%.1f%s", (base * nbytes / unit), suffix)
end
