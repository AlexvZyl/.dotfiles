# This should stay as the first method because it's used in a test
# (or change the test)
function checkname(fdef::Expr, name)
    fproto = fdef.args[1]
    (fdef.head === :where || fdef.head == :(::)) && return checkname(fproto, name)
    fdef.head === :call || return false
    if fproto isa Expr
        fproto.head == :(::) && return fproto.args[2] == name
        # A metaprogramming-generated function
        fproto.head === :$ && return true   # uncheckable, let's assume all is well
        # Is the check below redundant?
        fproto.head === :. || return false
        # E.g. `function Mod.bar.foo(a, b)`
        return checkname(fproto.args[end], name)
    end
    isa(fproto, Symbol) || isa(fproto, QuoteNode) || isa(fproto, Expr) || return false
    return checkname(fproto, name)
end
checkname(fname::Symbol, name::Symbol) = begin
    fname === name && return true
    startswith(string(name), string('#', fname, '#')) && return true
    string(name) == string(fname, "##kw") && return true
    return false
end
checkname(fname::Symbol, ::Nothing) = true
checkname(fname::QuoteNode, name) = checkname(fname.value, name)

function isfuncexpr(ex, name=nothing)
    # Strip any macros that wrap the method definition
    while ex isa Expr && ex.head === :macrocall && length(ex.args) == 3
        ex = ex.args[3]
    end
    isa(ex, Expr) || return false
    if ex.head === :function || ex.head === :(=)
        return checkname(ex.args[1], name)
    end
    return false
end

function linerange(def::Expr)
    start, haslinestart = findline(def, identity)
    stop, haslinestop  = findline(def, Iterators.reverse)
    (haslinestart & haslinestop) && return start:stop
    return nothing
end
linerange(arg) = linerange(convert(Expr, arg))  # Handle Revise's RelocatableExpr

function findline(ex, order)
    ex.head === :line && return ex.args[1], true
    for a in order(ex.args)
        a isa LineNumberNode && return a.line, true
        if a isa Expr
            ln, hasline = findline(a, order)
            hasline && return ln, true
        end
    end
    return 0, false
end

fileline(lin::LineInfoNode)   = String(lin.file), lin.line
fileline(lnn::LineNumberNode) = String(lnn.file), lnn.line

# This is piracy, but it's not ambiguous in terms of what it should do
Base.convert(::Type{LineNumberNode}, lin::LineInfoNode) = LineNumberNode(lin.line, lin.file)

# This regex matches the pseudo-file name of a REPL history entry.
const rREPL = r"^REPL\[(\d+)\]$"

"""
    src = src_from_file_or_REPL(origin::AbstractString, repl = Base.active_repl)

Read the source for a function from `origin`, which is either the name of a file
or "REPL[\$i]", where `i` is an integer specifying the particular history entry.
Methods defined at the REPL use strings of this form in their `file` field.

If you happen to have a file where the name matches `REPL[\$i]`, first pass it through
`abspath`.
"""
function src_from_file_or_REPL(origin::AbstractString, args...)
    # This Varargs design prevents an unnecessary error when Base.active_repl is undefined
    # and `origin` does not match "REPL[$i]"
    m = match(rREPL, origin)
    if m !== nothing
        return src_from_REPL(m.captures[1], args...)
    end
    isfile(origin) || return nothing
    return read(origin, String)
end

function src_from_REPL(origin::AbstractString, repl = Base.active_repl)
    hist_idx = parse(Int, origin)
    hp = repl.interface.modes[1].hist
    return hp.history[hp.start_idx+hist_idx]
end

function basepath(id::PkgId)
    id.name ∈ ("Main", "Base", "Core") && return ""
    loc = Base.locate_package(id)
    loc === nothing && return ""
    return dirname(dirname(loc))
end

"""
    path = maybe_fix_path(path)

Return a normalized, absolute path for a source file `path`.
"""
function maybe_fix_path(file)
    if !isabspath(file)
        # This may be a Base or Core method
        newfile = Base.find_source_file(file)
        if isa(newfile, AbstractString)
            file = normpath(newfile)
        end
    end
    return maybe_fixup_stdlib_path(file)
end

safe_isfile(x) = try isfile(x); catch; false end
const BUILDBOT_STDLIB_PATH = dirname(abspath(joinpath(String((@which uuid1()).file), "..", "..", "..")))
replace_buildbot_stdlibpath(str::String) = replace(str, BUILDBOT_STDLIB_PATH => Sys.STDLIB)
"""
    path = maybe_fixup_stdlib_path(path::String)

Return `path` corrected for julia issue [#26314](https://github.com/JuliaLang/julia/issues/26314) if applicable.
Otherwise, return the input `path` unchanged.

Due to the issue mentioned above, location info for methods defined one of Julia's standard libraries
are, for non source Julia builds, given as absolute paths on the worker that built the `julia` executable.
This function corrects such a path to instead refer to the local path on the users drive.
"""
function maybe_fixup_stdlib_path(path)
    if !safe_isfile(path)
        maybe_stdlib_path = replace_buildbot_stdlibpath(path)
        safe_isfile(maybe_stdlib_path) && return maybe_stdlib_path
    end
    return path
end

function postpath(filename, pre)
    idx = findfirst(pre, filename)
    idx === nothing && error(pre, " not found in ", filename)
    post = filename[first(idx) + length(pre) : end]
    post[1:1] == Base.Filesystem.path_separator && return post[2:end]
    return post
end

if Base.VERSION < v"1.1"
    function splitpath(p::String)
        # splitpath became available with Julia 1.1
        # Implementation copied from Base except doesn't handle the drive
        out = String[]
        isempty(p) && (pushfirst!(out,p))  # "" means the current directory.
        while !isempty(p)
            dir, base = _splitdir_nodrive(p)
            dir == p && (pushfirst!(out, dir); break)  # Reached root node.
            if !isempty(base)  # Skip trailing '/' in basename
                pushfirst!(out, base)
            end
            p = dir
        end
        return out
    end
    splitpath(p::AbstractString) = splitpath(String(p))

    _splitdir_nodrive(path::String) = _splitdir_nodrive("", path)
    function _splitdir_nodrive(a::String, b::String)
        m = match(Base.Filesystem.path_dir_splitter,b)
        m === nothing && return (a,b)
        a = string(a, isempty(m.captures[1]) ? m.captures[2][1] : m.captures[1])
        a, String(m.captures[3])
    end
end

# Robust across Julia versions
getpkgid(project::AbstractString, libname) = getpkgid(Base.project_deps_get(project, libname), libname)
getpkgid(id::PkgId, libname) = id
getpkgid(uuid::UUID, libname) = PkgId(uuid, libname)
