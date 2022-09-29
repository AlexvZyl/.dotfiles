# TODO very hacky, but passes spec.
function normalize_reference(str)
    if startswith(str, '[') && endswith(str, ']')
        str = chop(str; head=1, tail=1)
    end
    str = lowercase(Base.Unicode.normalize(str))
    str = strip(replace(str, r"\s+" => ' '))
    return isempty(str) ? "[]" : str
end
