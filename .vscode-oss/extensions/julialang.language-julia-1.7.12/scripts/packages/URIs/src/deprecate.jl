function Base.merge(uri::URI; kw...)
    Base.depwarn("`merge(uri::URI; kw...)` is deprecated, use `URI(uri; kw...)` instead.", :merge)
    return URI(uri; kw...)
end
