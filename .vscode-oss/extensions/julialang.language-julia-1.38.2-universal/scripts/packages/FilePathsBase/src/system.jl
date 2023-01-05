"""
    SystemPath

A union of `PosixPath` and `WindowsPath` which is used for writing
methods that wrap base functionality.
"""
abstract type SystemPath <: AbstractPath end

Path() = @static Sys.isunix() ? PosixPath() : WindowsPath()
Path(pieces::Tuple{Vararg{String}}) =
    @static Sys.isunix() ? PosixPath(pieces) : WindowsPath(pieces)

"""
    @__PATH__ -> SystemPath

@__PATH__ expands to a path with the directory part of the absolute path
of the file containing the macro. Returns an empty Path if run from a REPL or
if evaluated by julia -e <expr>.
"""
macro __PATH__()
    p = Path(dirname(string(__source__.file)))
    return p === nothing ? :(Path()) : :($p)
end

"""
    @__FILEPATH__ -> SystemPath

@__FILEPATH__ expands to a path with the absolute file path of the file
containing the macro. Returns an empty Path if run from a REPL or if
evaluated by julia -e <expr>.
"""
macro __FILEPATH__()
    p = Path(string(__source__.file))
    return p === nothing ? :(Path()) : :($p)
end

"""
    @LOCAL(filespec)

Construct an absolute path to `filespec` relative to the source file
containing the macro call.
"""
macro LOCAL(filespec)
    p = join(Path(dirname(string(__source__.file))), Path(filespec))
    return :($p)
end

exists(fp::SystemPath) = ispath(string(fp))

#=
The following a descriptive methods for paths
built around stat
=#
Base.stat(fp::SystemPath) = Status(stat(string(fp)))
Base.lstat(fp::SystemPath) = Status(lstat(string(fp)))

"""
    mode(fp::SystemPath) -> Mode

Returns the `Mode` for the specified path.

# Example
```
julia> mode(p"src/FilePathsBase.jl")
-rw-r--r--
```
"""
mode(fp::SystemPath) = stat(fp).mode
Base.filesize(fp::SystemPath) = stat(fp).size

"""
    modified(fp::SystemPath) -> DateTime

Returns the last modified date for the `path`.

# Example
```
julia> modified(p"src/FilePathsBase.jl")
2017-06-20T04:01:09
```
"""
modified(fp::SystemPath) = stat(fp).mtime

"""
    created(fp::SystemPath) -> DateTime

Returns the creation date for the `path`.

# Example
```
julia> created(p"src/FilePathsBase.jl")
2017-06-20T04:01:09
```
"""
created(fp::SystemPath) = stat(fp).ctime
Base.isdir(fp::SystemPath) = isdir(mode(fp))
Base.isfile(fp::SystemPath) = isfile(mode(fp))
Base.islink(fp::SystemPath) = islink(lstat(fp).mode)
Base.issocket(fp::SystemPath) = issocket(mode(fp))
Base.isfifo(fp::SystemPath) = issocket(mode(fp))
Base.ischardev(fp::SystemPath) = ischardev(mode(fp))
Base.isblockdev(fp::SystemPath) = isblockdev(mode(fp))

"""
    isexecutable(fp::SystemPath) -> Bool

Returns whether the `path` is executable for the current user.
"""
function isexecutable(fp::SystemPath)
    s = stat(fp)
    usr = User()

    return (
        isexecutable(s.mode, :ALL) ||
        isexecutable(s.mode, :OTHER) ||
        ( usr.uid == s.user.uid && isexecutable(s.mode, :USER) ) ||
        ( usr.gid == s.group.gid && isexecutable(s.mode, :GROUP) )
    )
end

"""
    iswritable(fp::AbstractPath) -> Bool

Returns whether the `path` is writable for the current user.
"""
function Base.iswritable(fp::SystemPath)
    s = stat(fp)
    usr = User()

    return (
        iswritable(s.mode, :ALL) ||
        iswritable(s.mode, :OTHER) ||
        ( usr.uid == s.user.uid && iswritable(s.mode, :USER) ) ||
        ( usr.gid == s.group.gid && iswritable(s.mode, :GROUP) )
    )
end

"""
    isreadable(fp::SystemPath) -> Bool

Returns whether the `path` is readable for the current user.
"""
function Base.isreadable(fp::SystemPath)
    s = stat(fp)
    usr = User()

    return (
        isreadable(s.mode, :ALL) ||
        isreadable(s.mode, :OTHER) ||
        ( usr.uid == s.user.uid && isreadable(s.mode, :USER) ) ||
        ( usr.gid == s.group.gid && isreadable(s.mode, :GROUP) )
    )
end

function Base.ismount(fp::SystemPath)
    isdir(fp) || return false
    s1 = lstat(fp)
    # Symbolic links cannot be mount points
    islink(fp) && return false
    s2 = lstat(parent(fp))
    # If a directory and its parent are on different devices,  then the
    # directory must be a mount point
    (s1.device != s2.device) && return true
    (s1.inode == s2.inode) && return true
    false
end

#=
Path Operations
===============================================
The following are methods for actually manipulating the
filesystem.

NOTE: Currently, we are just wrapping base julia functions,
but in the future we'll likely be handling platform specific
code in the implementation instances.

TODO: Document these once we're comfortable with them.
=#

Base.cd(fp::SystemPath) = cd(string(fp))
function Base.cd(fn::Function, dir::SystemPath)
    old = cwd()
    try
        cd(dir)
        fn()
   finally
        cd(old)
    end
end

function Base.mkdir(fp::T; mode=0o777, recursive=false, exist_ok=false) where T<:SystemPath
    if exists(fp)
        if exist_ok
            return fp
        else
            error("$fp already exists.")
        end
    else
        if hasparent(fp) && !exists(parent(fp))
			if recursive
				mkdir(parent(fp); mode=mode, recursive=recursive, exist_ok=exist_ok)
			else
				error(
					"The parent of $fp does not exist. " *
					"Pass recursive=true to create it."
				)
			end
        end

		return parse(T, mkdir(string(fp), mode=mode))
    end
end

function Base.symlink(src::SystemPath, dest::SystemPath; exist_ok=false, overwrite=false)
    if exists(src)
        if exists(dest) && exist_ok && overwrite
            rm(dest, recursive=true)
        end

        if !exists(dest)
            symlink(string(src), string(dest))
        elseif !exist_ok
            error("$dest already exists.")
        end
    else
        error("$src is not a valid path")
    end
end

function Base.rm(fp::SystemPath; kwargs...)
    rm(string(fp); kwargs...)
end
Base.touch(fp::T) where {T<:SystemPath} = parse(T, touch(string(fp)))
function Base.mktemp(parent::T) where T<:SystemPath
    fp, io = mktemp(string(parent))
    return parse(T, fp), io
end

Base.mktempdir(parent::T) where {T<:SystemPath}= parse(T, mktempdir(string(parent)))

"""
    chown(fp::SystemPath, user::AbstractString, group::AbstractString; recursive=false)

Change the `user` and `group` of the `fp`.
"""
function Base.chown(fp::SystemPath, user::AbstractString, group::AbstractString; recursive=false)
    @static if Sys.isunix()
        chown_cmd = String["chown"]
        if recursive
            push!(chown_cmd, "-R")
        end
        append!(chown_cmd, String["$(user):$(group)", string(fp)])

        run(Cmd(chown_cmd))
    else
        error("chown is currently not supported on windows.")
    end

    return fp
end

Base.chown(fp::T, args...) where {T<:SystemPath} = parse(T, chown(string(fp), args...))

"""
    chmod(fp::SystemPath, mode::Mode; recursive=false)
    chmod(fp::SystemPath, mode::Integer; recursive=false)
    chmod(fp::SystemPath, user::UIn8=0o0, group::UInt8=0o0, other::UInt8=0o0; recursive=false)
    chmod(fp::SystemPath, symbolic_mode::AbstractString; recursive=false)

Provides various methods for changing the `mode` of a `fp`.

# Examples
```julia-repl
julia> touch(p"newfile")
Base.Filesystem.File(false, RawFD(-1))

julia> mode(p"newfile")
-rw-r--r--

julia> chmod(p"newfile", 0o755)

julia> mode(p"newfile")
-rwxr-xr-x

julia> chmod(p"newfile", "-x")

julia> mode(p"newfile")
-rw-r--r--

julia> chmod(p"newfile", user=(READ+WRITE+EXEC), group=(READ+EXEC), other=READ)

julia> mode(p"newfile")
-rwxr-xr--

julia> chmod(p"newfile", mode(p"src/FilePathsBase.jl"))

julia> mode(p"newfile")
-rw-r--r--
```
"""
function Base.chmod(fp::T, mode::Mode; recursive=false) where T<:SystemPath
    chmod_path = string(fp)
    chmod_mode = raw(mode)

    if isdir(fp) && recursive
        for p in readdir(fp)
            parse(T, chmod(chmod_path, chmod_mode; recursive=recursive))
        end
    end

    parse(T, chmod(chmod_path, chmod_mode))
end

function Base.chmod(fp::SystemPath, mode::Integer; recursive=false)
    chmod(fp, Mode(mode); recursive=recursive)
end

function Base.chmod(fp::SystemPath; user::UInt8=0o0, group::UInt8=0o0, other::UInt8=0o0, recursive=false)
    chmod(fp, Mode(user=user, group=group, other=other); recursive=recursive)
end

function Base.chmod(fp::SystemPath, symbolic_mode::AbstractString; recursive=false)
    who_char = ['u', 'g', 'o']
    who_actual = [:USER, :GROUP, :OTHER]
    act_char = ['+', '-', '=']
    perm_char = ['r', 'w', 'x']
    perm_actual = [READ, WRITE, EXEC]
    unsupported_perm_char = ['s', 't', 'X', 'u', 'g', 'o']

    tokenized = split(symbolic_mode, act_char)
    if length(tokenized) != 2
        error("Invalid symbolic string expected format <who><action><perm>.")
    end

    who_raw = tokenized[1]
    perm_raw = tokenized[2]

    who = [:ALL]
    perm = 0o0

    for i in 1:3
        if who_char[i] in who_raw
            push!(who, who_actual[i])
        end
    end

    for i in 1:3
        if perm_char[i] in perm_raw
            perm += perm_actual[i]
        end
    end

    for x in unsupported_perm_char
        if x in perm_raw
            error("$x is currently an unsupported permission char for symbolic modes.")
        end
    end

    m = mode(fp)
    new_m = Mode(perm, who...)

    if '+' in symbolic_mode
        chmod(fp, m + new_m; recursive=recursive)
    elseif '-' in symbolic_mode
        chmod(fp, m - new_m; recursive=recursive)
    elseif '=' in symbolic_mode
        chmod(fp, new_m; recursive=recursive)
    else
        error("No valid action found in symbolic mode string.")
    end
end

Base.open(fp::SystemPath, args...) = open(string(fp), args...)
function Base.open(f::Function, fp::SystemPath, args...; kwargs...)
    open(f, string(fp), args...; kwargs...)
end

Base.read(fp::SystemPath) = read(string(fp))
function Base.write(fp::SystemPath, x::Union{String, Vector{UInt8}}, mode="w")
    open(fp, mode) do f
        write(f, x)
    end
end

Base.readdir(fp::SystemPath; kwargs...) = readdir(string(fp); kwargs...)

function Base.download(url::AbstractString, dest::T) where T<:SystemPath
    return parse(T, download(url, string(dest)))
end

function Base.readlink(fp::T) where T<:SystemPath
    return parse(T, readlink(string(fp)))
end

function canonicalize(fp::T) where T<:SystemPath
    return parse(T, realpath(string(fp)))
end

Mmap.mmap(fp::SystemPath, args...; kwargs...) = Mmap.mmap(string(fp), args...; kwargs...)

function Base.include(mapexpr::Function, m::Module, path::SystemPath)
    return Base.include(mapexpr, m, string(path))
end
