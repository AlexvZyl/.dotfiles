module URIs

export URI,
       queryparams, queryparampairs, absuri,
       escapeuri, unescapeuri, escapepath,
       resolvereference

import Base.==

const DEBUG_LEVEL = Ref(0)
include("debug.jl")
include("parseutils.jl")

struct ParseError <: Exception
    msg::String
end

"""
    URI(; scheme="", host="", port="", etc...)
    URI(str) = parse(URI, str::String)

A type representing a URI (e.g. a URL). Can be constructed from distinct parts using the various
supported keyword arguments, or from a string. The `URI` constructors will automatically escape any provided
`query` arguments, typically provided as `"key"=>"value"::Pair` or `Dict("key"=>"value")`.
Note that multiple values for a single query key can provided like `Dict("key"=>["value1", "value2"])`.

When constructing a `URI` from a `String`, you need to first unescape that string: `URI( URIs.unescapeuri(str) )`.

The `URI` struct stores the complete URI in the `uri::String` field and the
component parts in the following `SubString` fields:
  * `scheme`, e.g. `"http"` or `"https"`
  * `userinfo`, e.g. `"username:password"`
  * `host` e.g. `"julialang.org"`
  * `port` e.g. `"80"` or `""`
  * `path` e.g `"/"`
  * `query` e.g. `"Foo=1&Bar=2"`
  * `fragment`

The `queryparams(::URI)` function returns a `Dict` containing the `query`.
"""
struct URI
    uri::String
    scheme::SubString{String}
    userinfo::SubString{String}
    host::SubString{String}
    port::SubString{String}
    path::SubString{String}
    query::SubString{String}
    fragment::SubString{String}
end

const absent = SubString("absent", 1, 0)

const emptyuri = (()->begin
    uri = ""
    return URI(uri, absent, absent, absent, absent, absent, absent, absent)
end)()

const nostring = ""

function URI(uri::URI; scheme::AbstractString=uri.scheme,
                              userinfo::AbstractString=uri.userinfo,
                              host::AbstractString=uri.host,
                              port::Union{Integer,AbstractString}=uri.port,
                              path::AbstractString=uri.path,
                              query=uri.query,
                              fragment::AbstractString=uri.fragment)

    @require isempty(host) || host[end] != '/'
    @require scheme in uses_authority || isempty(host)
    @require !isempty(host) || isempty(port)
    @require !(scheme in ["http", "https"]) || isempty(path) || path[1] == '/'
    @require !isempty(path) || !isempty(query) || isempty(fragment)

    if port !== absent
        port = string(port)
    end
    querys = query isa AbstractString ? query : escapeuri(query)

    return URI(nostring, scheme, userinfo, host, port, path, querys, fragment)
end

URI(;kw...) = URI(emptyuri; kw...)

# Based on regex from RFC 3986:
# https://tools.ietf.org/html/rfc3986#appendix-B
const uri_reference_regex = RegexAndMatchData[]
function uri_reference_regex_f()
    r = RegexAndMatchData(r"""^
    (?: ([^:/?#]+) :) ?                     # 1. scheme
    (?: // (?: ([^/?#@]*) @) ?              # 2. userinfo
           (?| (?: \[ ([^:\]]*:[^\]]*) \] ) # 3. host (ipv6)
             | ([^:/?#\[]*) )               # 3. host
           (?: : ([^/?#]*) ) ? ) ?          # 4. port
    ([^?#]*)                                # 5. path
    (?: \?([^#]*) ) ?                       # 6. query
    (?: [#](.*) ) ?                         # 7. fragment
    $"""x)
    Base.compile(r.re)
    initialize!(r)
    r
end

"""
https://tools.ietf.org/html/rfc3986#section-3
"""
function parse_uri(str::AbstractString; kw...)
    uri = parse_uri_reference(str; kw...)
    if isempty(uri.scheme)
        throw(URIs.ParseError("URI without scheme: $str"))
    end
    return uri
end

"""
https://tools.ietf.org/html/rfc3986#section-4.1
"""
function parse_uri_reference(str::Union{String, SubString{String}};
                             strict = false)
    uri_reference_re = access_threaded(uri_reference_regex_f, uri_reference_regex)
    if !exec(uri_reference_re, str)
        throw(ParseError("URI contains invalid character"))
    end
    uri = URI(str, group(1, uri_reference_re, str, absent),
                   group(2, uri_reference_re, str, absent),
                   group(3, uri_reference_re, str, absent),
                   group(4, uri_reference_re, str, absent),
                   group(5, uri_reference_re, str, absent),
                   group(6, uri_reference_re, str, absent),
                   group(7, uri_reference_re, str, absent))
    if strict
        ensurevalid(uri)
        @ensure uristring(uri) == str
    end
    return uri
end

parse_uri_reference(str; strict = false) =
    parse_uri_reference(SubString(str); strict = false)

URI(str::AbstractString) = parse_uri_reference(str)

Base.parse(::Type{URI}, str::AbstractString) = parse_uri_reference(str)

function ensurevalid(uri::URI)
    # https://tools.ietf.org/html/rfc3986#section-3.1
    # ALPHA *( ALPHA / DIGIT / "+" / "-" / "." )
    if !(uri.scheme === absent ||
         occursin(r"^[[:alpha:]][[:alnum:]+-.]*$", uri.scheme))
        throw(ParseError("Invalid URI scheme: $(uri.scheme)"))
    end
    # https://tools.ietf.org/html/rfc3986#section-3.2.2
    # unreserved / pct-encoded / sub-delims
    if !(uri.host === absent ||
         occursin(r"^[:[:alnum:]\-._~%!$&'()*+,;=]+$", uri.host))
        throw(ParseError("Invalid URI host: $(uri.host) $uri"))
    end
    # https://tools.ietf.org/html/rfc3986#section-3.2.3
    # "port number in decimal"
    if !(uri.port === absent || occursin(r"^\d+$", uri.port))
        throw(ParseError("Invalid URI port: $(uri.port)"))
    end

    # https://tools.ietf.org/html/rfc3986#section-3.3
    # unreserved / pct-encoded / sub-delims / ":" / "@"
    if !(uri.path === absent ||
         occursin(r"^[/[:alnum:]\-._~%!$&'()*+,;=:@]*$", uri.path))
        throw(ParseError("Invalid URI path: $(uri.path)"))
    end

    # FIXME
    # For compatibility with existing test/uri.jl
    if !(uri.host === absent) &&
        (occursin("=", uri.host) ||
         occursin(";", uri.host) ||
         occursin("%", uri.host))
        throw(ParseError("Invalid URI host: $(uri.host)"))
    end
end

"""
https://tools.ietf.org/html/rfc3986#section-4.3
"""
isabsolute(uri::URI) =
    !isempty(uri.scheme) &&
     isempty(uri.fragment) &&
    (isempty(uri.host) || isempty(uri.path) || isabspath(uri))

"""
https://tools.ietf.org/html/rfc7230#section-5.3.1
https://tools.ietf.org/html/rfc3986#section-3.3
"""
isabspath(uri::URI) = startswith(uri.path, "/") && !startswith(uri.path, "//")

==(a::URI,b::URI) = a.scheme      == b.scheme      &&
                    a.host        == b.host        &&
                    normalport(a) == normalport(b) &&
                    a.path        == b.path        &&
                    a.query       == b.query       &&
                    a.fragment    == b.fragment    &&
                    a.userinfo    == b.userinfo

normalport(uri::URI) = uri.scheme == "http"  && uri.port == "80" ||
                       uri.scheme == "https" && uri.port == "443" ?
                       "" : uri.port

hoststring(h) = ':' in h ? "[$h]" : h

Base.show(io::IO, uri::URI) = print(io, "URI(\"", uri, "\")")

showparts(io::IO, uri::URI) =
    print(io, "URI(\"", uri.uri, "\"\n",
              "    scheme = \"", uri.scheme, "\"",
                       uri.scheme === absent ? " (absent)" : "", ",\n",
              "    userinfo = \"", uri.userinfo, "\"",
                       uri.userinfo === absent ? " (absent)" : "", ",\n",
              "    host = \"", uri.host, "\"",
                       uri.host === absent ? " (absent)" : "", ",\n",
              "    port = \"", uri.port, "\"",
                       uri.port === absent ? " (absent)" : "", ",\n",
              "    path = \"", uri.path, "\"",
                       uri.path === absent ? " (absent)" : "", ",\n",
              "    query = \"", uri.query, "\"",
                       uri.query === absent ? " (absent)" : "", ",\n",
              "    fragment = \"", uri.fragment, "\"",
                       uri.fragment === absent ? " (absent)" : "", ")\n")

showparts(uri::URI) = showparts(stdout, uri)

Base.print(io::IO, u::URI) = print(io, string(u))

Base.string(u::URI) = u.uri === nostring ? uristring(u) : u.uri

#isabsent(ui) = isempty(ui) && !(ui === blank)
isabsent(ui) = ui === absent

function formaturi(io::IO,
                   scheme::AbstractString,
                   userinfo::AbstractString,
                   host::AbstractString,
                   port::AbstractString,
                   path::AbstractString,
                   query::AbstractString,
                   fragment::AbstractString)

    isempty(scheme)      || print(io, scheme, isabsent(host) ?
                                           ":" : "://")
    isabsent(userinfo)   || print(io, userinfo, "@")
    isempty(host)        || print(io, hoststring(host))
    isabsent(port)       || print(io, ":", port)
    isempty(path)        || print(io, path)
    isabsent(query)      || print(io, "?", query)
    isabsent(fragment)   || print(io, "#", fragment)

    return io
end

uristring(a...) = String(take!(formaturi(IOBuffer(), a...)))

uristring(u::URI) = uristring(u.scheme, u.userinfo, u.host, u.port,
                              u.path, u.query, u.fragment)

"""
    queryparams(::URI) -> Dict
    queryparams(query_str::AbstractString) -> Dict

Returns a `Dict` containing the `query` parameter string parsed according to
the key=value pair formatting convention.

Note that duplicate query param values are not supported; if needed, use `queryparampairs`.

Note that this is not part of the formal URI grammar, merely a common parsing
convention — see [RFC 3986](https://tools.ietf.org/html/rfc3986#section-3.4).
"""
queryparams(uri::URI) = queryparams(uri.query)

function queryparams(q::AbstractString)
    Dict{String,String}(unescapeuri(decodeplus(k)) => unescapeuri(decodeplus(v))
                        for (k,v) in ([split(e, "=")..., ""][1:2]
                                      for e in split(q, "&", keepempty=false)))
end

"""
    queryparampairs(::URI) -> Vector{Pair{String, String}}
    queryparampairs(query_str::AbstractString) -> Vector{Pair{String, String}}

Identical to `queryparams`, but returns a `Vector{Pair{String, String}}` containing the `query` parameter string parsed according to
the key=value pair formatting convention.

Note that this is not part of the formal URI grammar, merely a common parsing
convention — see [RFC 3986](https://tools.ietf.org/html/rfc3986#section-3.4).
"""
queryparampairs(uri::URI) = queryparampairs(uri.query)

function queryparampairs(q::AbstractString)
    [unescapeuri(decodeplus(k)) => unescapeuri(decodeplus(v))
                        for (k,v) in ([split(e, "=")..., ""][1:2]
                                      for e in split(q, "&", keepempty=false))]
end

# Validate known URI formats
const uses_authority = ["https", "http", "ws", "wss", "hdfs", "ftp", "gopher", "nntp", "telnet", "imap", "wais", "file", "mms", "shttp", "snews", "prospero", "rtsp", "rtspu", "rsync", "svn", "svn+ssh", "sftp" ,"nfs", "git", "git+ssh", "ldap", "s3", "ssh"]
const non_hierarchical = ["gopher", "hdl", "mailto", "news", "telnet", "wais", "imap", "snews", "sip", "sips"]
const uses_query = ["http", "wais", "imap", "https", "shttp", "mms", "gopher", "rtsp", "rtspu", "sip", "sips", "ldap"]
const uses_fragment = ["hdfs", "ftp", "hdl", "http", "gopher", "news", "nntp", "wais", "https", "shttp", "snews", "file", "prospero"]

"checks if a `URI` is valid"
function Base.isvalid(uri::URI)
    sch = uri.scheme
    isempty(sch) && throw(ArgumentError("can not validate relative URI"))
    if ((sch in non_hierarchical) && (i = findfirst(isequal('/'), uri.path); i !== nothing && i > 1)) ||       # path hierarchy not allowed
       (!(sch in uses_query) && !isempty(uri.query)) ||                    # query component not allowed
       (!(sch in uses_fragment) && !isempty(uri.fragment)) ||              # fragment identifier component not allowed
       (!(sch in uses_authority) && (!isempty(uri.host) || ("" != uri.port) || !isempty(uri.userinfo))) # authority component not allowed
        return false
    end
    return true
end

# RFC3986 Unreserved Characters (and '~' Unsafe per RFC1738).
@inline issafe(c::Char) = c == '-' ||
                          c == '.' ||
                          c == '_' ||
                          (isascii(c) && (isletter(c) || isnumeric(c)))

"""
    _bytes(s::String)

Get a `Vector{UInt8}`, a vector of bytes of a string.
"""
function _bytes end
_bytes(s::SubArray{UInt8}) = unsafe_wrap(Array, pointer(s), length(s))

_bytes(s::Union{Vector{UInt8}, Base.CodeUnits}) = _bytes(String(s))
_bytes(s::String) = codeunits(s)
_bytes(s::SubString{String}) = codeunits(s)

_bytes(s::Vector{UInt8}) = s


utf8_chars(str::AbstractString) = (Char(c) for c in _bytes(str))

"""
    escapeuri(x)

Apply URI percent-encoding to escape special characters in `x`.
"""
function escapeuri end

escapeuri(c::Char) = string('%', uppercase(string(Int(c), base=16, pad=2)))
escapeuri(str::AbstractString, safe::Function=issafe) =
    join(safe(c) ? c : escapeuri(c) for c in utf8_chars(str))

escapeuri(bytes::Vector{UInt8}) = bytes
escapeuri(v::Number) = escapeuri(string(v))
escapeuri(v::Symbol) = escapeuri(string(v))

"""
    escapeuri(key, value)
    escapeuri(query_vals)

Percent-encode and concatenate a value pair(s) as they would conventionally be
encoded within the query part of a URI.
"""
escapeuri(key, value) = string(escapeuri(key), "=", escapeuri(value))
escapeuri(key, values::Vector) = escapeuri(key => v for v in values)
escapeuri(query) = isempty(query) ? absent : join((escapeuri(k, v) for (k,v) in query), "&")
escapeuri(nt::NamedTuple) = escapeuri(pairs(nt))

decodeplus(q) = replace(q, '+' => ' ')

"""
    unescapeuri(str)

Percent-decode a string according to the URI escaping rules.
"""
function unescapeuri(str)
    occursin("%", str) || return str
    out = IOBuffer()
    i = 1
    io = IOBuffer(str)
    while !eof(io)
        c = read(io, Char)
        if c == '%'
            c1 = read(io, Char)
            c = read(io, Char)
            write(out, parse(UInt8, string(c1, c); base=16))
        else
            write(out, c)
        end
    end
    return String(take!(out))
end

ispathsafe(c::Char) = c == '/' || issafe(c)
"""
    escapepath(path)

Escape the path portion of a URI, given the string `path` containing embedded
`/` characters which separate the path segments.
"""
escapepath(path) = escapeuri(path, ispathsafe)

"""
    URIs.splitpath(path|uri; rstrip_empty_segment=true)

Splits the path into component segments based on `/`, according to
http://tools.ietf.org/html/rfc3986#section-3.3. Any fragment and query parts of
the string are ignored if present.

A final empty path segment (trailing '/') is removed, if present. This is
technically incompatible with the segment grammar of RFC3986, but it seems to
be a common recommendation to make paths with and without a trailing slash
equivalent. To preserve any final empty path segment, set
`rstrip_empty_segment=false`.

# Examples

```jldoctest
julia> URIs.splitpath(URI("http://example.com/foo/bar?a=b&c=d"))
2-element Array{String,1}:
 "foo"
 "bar"

julia> URIs.splitpath("/foo/bar/")
2-element Array{String,1}:
 "foo"
 "bar"
```
"""
function splitpath(path::AbstractString; rstrip_empty_segment::Bool=true)
    elems = String[]
    n = ncodeunits(path)
    n > 0 || return elems
    i = path[1] == '/' ? 1 : 0
    start_ind = i + 1
    while true
        nexti = nextind(path, i)
        if nexti > n
            break
        end
        c = path[nexti]
        if c in ('?', '#')
            break
        end
        if c == '/'
            push!(elems, path[start_ind:i])
            start_ind = nexti + 1
        end
        i = nexti
    end
    push!(elems, path[start_ind:i])
    if rstrip_empty_segment && !isempty(elems) && isempty(elems[end])
        # Trailing slashes do not introduce a final segment by default.  This is
        # technically incompatible with the grammar of RFC3986, but seems to be
        # a common convention, and was present in URIs 1.0
        pop!(elems)
    end
    return elems
end

splitpath(uri::URI; kws...) = splitpath(uri.path; kws...)

"""
    URIs.normpath(url)

Normalize the path portion of a URI by removing dot segments. This function
corresponds to the `remove_dot_segments` function described in Sec. 5.2.4 of
IETF RFC 3986.

Refer to:
* https://tools.ietf.org/html/rfc3986#section-5.2.4
"""
normpath(url::URI) =
    URI(scheme=url.scheme, userinfo=url.userinfo, host=url.host, port=url.port,
        path=normpath(url.path), query=url.query, fragment=url.fragment)

# normpath helper functions
_tail(s, prefix) = last(s, length(s) - length(prefix))
function _pop_segment(buf)
    last_slash = findlast('/', buf)
    (last_slash === nothing) ? "" : buf[firstindex(buf):prevind(buf, last_slash)]
end

function normpath(p::AbstractString)
    # Ref: IETF RFC 3986 Sec. 5.2.4
    # https://datatracker.ietf.org/doc/html/rfc3986#section-5.2.4
    output = ""

    while !isempty(p)
        # Condition A
        p = if startswith(p, "./")
            _tail(p, "./")
        elseif startswith(p, "../")
            _tail(p, "../")
        # Condition B
        elseif startswith(p, "/./")
            "/" * _tail(p, "/./")
        elseif p == "/."
            "/"
        # Condition C
        elseif startswith(p, "/../")
            output = _pop_segment(output)
            "/" * _tail(p, "/../")
        elseif p == "/.."
            output = _pop_segment(output)
            "/"
        # Condition D
        elseif occursin(r"^\.+$", p)
            last(p, 0)
        # Condition E
        else
            next_slash = findnext(isequal('/'), p, nextind(p, 1))
            if (next_slash === nothing)
                output = output * p
                last(p, 0)
            else
                prefix = p[firstindex(p):prevind(p, next_slash)]
                output = output * prefix
                _tail(p, prefix)
            end
        end
    end

    output
end

absuri(u, context) = absuri(URI(u), URI(context))

"""
    absuri(uri::Union{URI,AbstractString}, context::Union{URI,AbstractString}) -> URI

Construct an absolute URI, using `uri.path` and `uri.query` and filling in
other components from `context`.
"""
function absuri(uri::URI, context::URI)

    if !isempty(uri.host)
        return uri
    end

    @assert !isempty(context.scheme)
    @assert !isempty(context.host)
    @assert isempty(uri.port)

    return URI(context; path=uri.path, query=uri.query)
end

"""
    joinpath(uri::URI, path::AbstractString) -> URI

Join the path component of URI and other parts.
"""
function Base.joinpath(uri::URI, parts::String...)
    path = uri.path
    for p in parts
        if startswith(p, '/')
            path = p
        elseif isempty(path) || endswith(path, '/')
            path *= p
        else
            path *= "/" * p
        end
    end

    if isempty(uri.path)
        path = "/" * path
    end
    return URI(uri; path=normpath(path))
end

"""
    resolvereference(base::Union{URI,AbstractString}, ref::Union{URI,AbstractString}) -> URI

Resolve a URI reference `ref` relative to the absolute base URI `base`,
complying with [RFC 3986 Section 5.2](https://tools.ietf.org/html/rfc3986#section-5.2).

If `ref` is an absolute URI, return `ref` unchanged.

# Examples

```jldoctest; setup = :(using URIs)
julia> u = resolvereference("http://example.org/foo/bar/", "/baz/")
URI("http://example.org/baz/")

julia> resolvereference(u, "./hello/world")
URI("http://example.org/baz/hello/world")

julia> resolvereference(u, "http://localhost:8000")
URI("http://localhost:8000")
```
"""
function resolvereference(base::URI, ref::URI)
    # In the case where the second URI is absolute, we just return the
    # reference URI. Refer to https://tools.ietf.org/html/rfc3986#section-5.2.2
    #
    # We also default to just returning the reference when the base URI is
    # non-absolute.
    if isempty(base.scheme) || !isempty(ref.scheme)
        return ref
    end

    host, port, path, query = if !isempty(ref.host)
        ref.host, ref.port, ref.path, ref.query
    else
        path, query = if isempty(ref.path)
            base.path, isempty(ref.query) ? base.query : ref.query
        else
            path = startswith(ref.path, "/") ? ref.path : resolveref_merge(base, ref)
            path, ref.query
        end
        base.host, base.port, path, query
    end

    path = normpath(path)
    scheme = base.scheme
    fragment = ref.fragment
    userinfo = isempty(ref.userinfo) ? base.userinfo : ref.userinfo

    URI(;
        scheme=scheme,
        userinfo=userinfo,
        host=host,
        port=port,
        path=path,
        query=query,
        fragment=fragment
    )
end

resolvereference(base, ref) = resolvereference(URI(base), URI(ref))

"""
    resolveref_merge(base, ref)

Implementation of the "merge" routine described in RFC 3986 Sec. 5.2.3 for merging
a relative-path reference with the path of the base URI.
"""
function resolveref_merge(base, ref)
    if !isempty(base.host) && isempty(base.path)
        "/" * ref.path
    else
        last_slash = findprev("/", base.path, lastindex(base.path))
        if last_slash === nothing
            ref.path
        else
            last_slash = first(last_slash)
            base.path[1:last_slash] * ref.path
        end
    end
end


function access_threaded(f, v::Vector)
    tid = Threads.threadid()
    0 < tid <= length(v) || _length_assert()
    if @inbounds isassigned(v, tid)
        @inbounds x = v[tid]
    else
        x = f()
        @inbounds v[tid] = x
    end
    return x
end
@noinline _length_assert() =  @assert false "0 < tid <= v"

function __init__()
    resize!(empty!(uri_reference_regex), Threads.nthreads())
    return
end

include("deprecate.jl")

end # module
