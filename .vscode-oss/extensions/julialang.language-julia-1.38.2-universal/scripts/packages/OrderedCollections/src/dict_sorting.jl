# Sort for dicts
import Base: sort, sort!

function sort!(d::OrderedDict; byvalue::Bool=false, args...)
    if d.ndel > 0
        rehash!(d)
    end

    if byvalue
        p = sortperm(d.vals; args...)
    else
        p = sortperm(d.keys; args...)
    end
    d.keys = d.keys[p]
    d.vals = d.vals[p]
    rehash!(d)
    return d
end

sort(d::OrderedDict; args...) = sort!(copy(d); args...)
@deprecate sort(d::Dict; args...) sort!(OrderedDict(d); args...)

function sort(d::LittleDict; byvalue::Bool=false, args...)
    if byvalue
        p = sortperm(d.vals; args...)
    else
        p = sortperm(d.keys; args...)
    end
    return LittleDict(d.keys[p], d.vals[p])
end

