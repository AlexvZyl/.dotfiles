struct Mode
    m::UInt64
end

"""
    Mode(m::UInt8)
    Mode(;user::UInt8=0o0, group::UInt8=0o0, other::UInt8=0o0)
    Mode(mode::UInt8, usr_grps::Symbol...)
    Mode(str)

Provides an abstraction for working with posix file permissions.
A lot of the low level permissions code for this type was below
and the corresponding constants have been translated from
cpython's [Lib/stat.py](https://github.com/python/cpython/blob/master/Lib/stat.py).

# Example
```julia-repl
julia> Mode("-rwxr-x--x")
-rwxr-x--x
```
"""
function Mode(;user::UInt8=0o0, group::UInt8=0o0, other::UInt8=0o0,)
    @assert user <= 0o7 && group <= 0o7 && other <= 0o7

    Mode(user * USER_COEFF | group * GROUP_COEFF | other * OTHER_COEFF)
end

function Mode(mode::UInt8, usr_grps::Symbol...)
    user = group = other = 0o0

    for usr_grp in usr_grps
        if usr_grp == :ALL
            user = group = other = mode
            break
        elseif usr_grp == :USER
            user = mode
        elseif usr_grp == :GROUP
            group = mode
        elseif usr_grp == :OTHER
            other = mode
        else
            throw(ArgumentError(
                "$usr_grp not a valid symbol only " *
                ":ALL, :USER, :GROUP and :OTHER are accepted."
            ))
        end
    end

    return Mode(user=user, group=group, other=other)
end

Mode(s::AbstractString) = parse(Mode, s)

function Base.parse(::Type{Mode}, x::AbstractString)
    n = length(FILEMODE_TABLE)

    if length(x) != n
        throw(ArgumentError(
            "Expected a mode permission string with $n characters (e.g., '-rwxrwxrwx')"
        ))
    end

    m = zero(UInt64)
    for i in 1:n
        table = FILEMODE_TABLE[i]
        found = false
        c = x[i]
        c == '-' && continue

        for (bit, char) in table
            if c == char
                m |= bit
                found = true
                break
            end
        end
        if !found
            options = last.(table)
            throw(ArgumentError(
                "Unknown character '$c' at position $i, expected one of $options."
            ))
        end
    end

    return Mode(m)
end

"""Convert a file's mode to a string of the form '-rwxrwxrwx'."""
function Base.print(io::IO, mode::Mode)
    n = length(FILEMODE_TABLE)
    perm = Vector{Char}(undef, n)

    for i in 1:n
        table = FILEMODE_TABLE[i]
        found = false
        for (bit, char) in table
            if mode.m & bit == bit
                perm[i] = char
                found = true
                break
            end
        end
        if !found
            perm[i] = '-'
        end
    end

    print(io, String(perm))
end

function Base.show(io::IO, mode::Mode)
    get(io, :compact, false) ? print(io, mode) : print(io, "Mode(\"$mode\")")
end

Base.:-(a::Mode, b::Mode) = Mode(a.m & ~b.m)
Base.:+(a::Mode, b::Mode) = Mode(a.m | b.m)

executable(usr_grps::Symbol...) = Mode(EXEC, usr_grps...)
readable(usr_grps::Symbol...) = Mode(READ, usr_grps...)
writable(usr_grps::Symbol...) = Mode(WRITE, usr_grps...)

function isexecutable(mode::Mode, usr_grp::Symbol)
    mask = S_IXOTH | S_IXGRP | S_IXUSR

    if usr_grp == :OTHER
        mask = S_IXOTH
    elseif usr_grp == :GROUP
        mask = S_IXGRP
    elseif usr_grp == :USER
        mask = S_IXUSR
    end

    return mode.m & mask == mask
end

function Base.iswritable(mode::Mode, usr_grp::Symbol)
    mask = S_IWOTH | S_IWGRP | S_IWUSR

    if usr_grp == :OTHER
        mask = S_IWOTH
    elseif usr_grp == :GROUP
        mask = S_IWGRP
    elseif usr_grp == :USER
        mask = S_IWUSR
    end

    return mode.m & mask == mask
end

function Base.isreadable(mode::Mode, usr_grp::Symbol)
    mask = S_IROTH | S_IRGRP | S_IRUSR

    if usr_grp == :OTHER
        mask = S_IROTH
    elseif usr_grp == :GROUP
        mask = S_IRGRP
    elseif usr_grp == :USER
        mask = S_IRUSR
    end

    return mode.m & mask == mask
end

Base.oct(mode::Mode) = oct(mode.m)
raw(mode::Mode) = mode.m

"""Return True if mode is from a directory."""
Base.isdir(mode::Mode) = _meta(mode.m) == S_IFDIR

"""Return True if mode is from a regular file."""
Base.isfile(mode::Mode) = _meta(mode.m) == S_IFREG

"""Return True if mode is from a symbolic link."""
Base.islink(mode::Mode) = _meta(mode.m) == S_IFLNK

"""Return True if mode is from a socket."""
Base.issocket(mode::Mode) = _meta(mode.m) == S_IFSOCK

"""Return True if mode is from a FIFO (named pipe)."""
Base.isfifo(mode::Mode) = _meta(mode.m) == S_IFIFO

"""Return True if mode is from a character special device file."""
Base.ischardev(mode::Mode) = _meta(mode.m) == S_IFCHR

"""Return True if mode is from a block special device file."""
Base.isblockdev(mode::Mode) = _meta(mode.m) == S_IFBLK

"""
Return the portion of the file's mode that can be set by
os.chmod().
"""
_mode(mode) = mode & 0o7777

"""
Return the portion of the file's mode that describes the
file type.
"""
_meta(mode) = mode & 0o170000
