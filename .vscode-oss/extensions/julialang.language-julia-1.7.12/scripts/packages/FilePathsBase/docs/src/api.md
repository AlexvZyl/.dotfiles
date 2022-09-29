# API

To compare and contrast `FilePathsBase` with `Base.Filesystem` we provide tables for common operations.
Use `?` at the REPL to get the documentation and arguments as they may be different than the base implementations.

## Operations

A table of common operations with Filesystem and FilePathsBase.

Filesystem | FilePathsBase.jl
--- | ---
"/home/user/docs" | p"/home/user/docs"
N/A | Path()
pwd() | pwd(SystemPath) or cwd()
homedir() | homedir(SystemPath) or home()
cd() | cd()
joinpath() | /
basename() | basename()
N/A | hasparent, parents, parent
splitext | splitext
N/A | filename
N/A | extension
N/A | extensions
ispath | exists
realpath | canonicalize
normpath | normalize
abspath | absolute
relpath | relative
stat | stat
lstat | lstat
filemode | mode
filesize | filesize
mtime | modified
ctime | created
isdir | isdir
isfile | isfile
islink | islink
issocket | issocket
isfifo | isfifo
ischardev | ischardev
isblockdev | isblockdev
isexecutable (deprecated) | isexecutable
iswritable (deprecated) | iswritable
isreadable (deprecated) | isreadable
ismount | ismount
isabspath | isabsolute
splitdrive()[1] | drive
N/A | root (property)
split(p, "/") | segments (property)
expanduser | expanduser
mkdir | mkdir
mkpath | N/A (use mkdir)
symlink | symlink
cp | cp
mv | mv
download | download
readdir | readdir
N/A | readpath
walkpath | walkpath
rm | rm
touch | touch
tempname() | tempname(::Type{<:AbstractPath}) (or tmpname)
tempdir() | tempdir(::Type{<:AbstractPath}) (or tmpdir)
mktemp() | mktemp(::Type{<:AbstractPath}) (or mktmp)
mktempdir() | mktempdir(::Type{<:AbstractPath}) (or mktmpdir)
chmod | chmod (recursive unix-only)
chown (unix only) | chown (unix only)
read | read
write | write
@__DIR__ | @__PATH__
@__FILE__ | @__FILEPATH__

## Aliases

A slightly reduced list of operations/aliases that will work with both strings and path types.
The `Filesystem` and `FilePathsBase` columns indicate what type will be returned from each
each library. As you'd expect, most return types match the input argument(s).

Function Name | Filesystem | FilePathsBase
--- | --- | ---
cd | AbstractString | AbstractPath
joinpath | AbstractString | AbstractPath
basename | AbstractString | AbstractString
splitext | (AbstractString, AbstractString) | (AbstractPath, AbstractString)
ispath | Bool | Bool
realpath | AbstractString | AbstractPath
normpath | AbstractString | AbstractPath
abspath | AbstractString | AbstractPath
relpath | AbstractString | AbstractPath
stat | StatStruct | FilePathsBase.Status
lstat | StatStruct | FilePathsBase.Status
filemode | UInt64 | FilePathsBase.Mode
filesize | Int64 | Int64
mtime | Float64 | Float64
ctime | Float64 | Float64
isdir | Bool | Bool
isfile | Bool | Bool
islink | Bool | Bool
issocket | Bool | Bool
isfifo | Bool | Bool
ischardev | Bool | Bool
isblockdev | Bool | Bool
ismount | Bool | Bool
isabspath | Bool | Bool
expanduser | AbstractString | AbstractPath
mkdir | AbstractString | AbstractPath
mkpath | AbstractString | AbstractPath
symlink | Nothing | Nothing
cp | AbstractString | AbstractPath
mv | AbstractString | AbstractPath
download | AbstractString | AbstractPath
readdir | AbstractString | AbstractString
rm | Nothing | Nothing
touch | AbstractString | AbstractPath
chmod | AbstractString | AbstractPath
chown | AbstractString | AbstractPath
read(fp, T) | T | T
write | Int64 | Int64


```@meta
DocTestSetup = quote
    using FilePathsBase
    using FilePathsBase: /
end
```

```@docs
FilePathsBase.AbstractPath
FilePathsBase.Path
FilePathsBase.SystemPath
FilePathsBase.PosixPath
FilePathsBase.WindowsPath
FilePathsBase.Mode
FilePathsBase.@p_str
FilePathsBase.@__PATH__
FilePathsBase.@__FILEPATH__
FilePathsBase.@LOCAL
FilePathsBase.cwd
FilePathsBase.home
FilePathsBase.hasparent
FilePathsBase.parents
FilePathsBase.parent
Base.:(*)(::P, ::Union{P, AbstractString, Char}...) where P <: AbstractPath
FilePathsBase.:(/)(::AbstractPath, ::Union{AbstractPath, AbstractString}...)
FilePathsBase.join(::T, ::Union{AbstractPath, AbstractString}...) where T <: AbstractPath
FilePathsBase.filename(::AbstractPath)
FilePathsBase.extension(::AbstractPath)
FilePathsBase.extensions(::AbstractPath)
Base.isempty(::AbstractPath)
normalize(::T) where {T <: AbstractPath}
absolute(::AbstractPath)
FilePathsBase.isabsolute(::AbstractPath)
FilePathsBase.relative(::T, ::T) where {T <: AbstractPath}
Base.readlink(::AbstractPath)
FilePathsBase.canonicalize(::AbstractPath)
FilePathsBase.mode(::AbstractPath)
FilePathsBase.modified(::AbstractPath)
FilePathsBase.created(::AbstractPath)
FilePathsBase.isexecutable
Base.iswritable(::PosixPath)
Base.isreadable(::PosixPath)
Base.cp(::AbstractPath, ::AbstractPath)
Base.mv(::AbstractPath, ::AbstractPath)
Base.download(::AbstractString, ::AbstractPath)
FilePathsBase.readpath
FilePathsBase.walkpath
FilePathsBase.diskusage
Base.open(::AbstractPath)
FilePathsBase.tmpname
FilePathsBase.tmpdir
FilePathsBase.mktmp
FilePathsBase.mktmpdir
Base.chown(::PosixPath, ::AbstractString, ::AbstractString)
Base.chmod(::PosixPath, ::Mode)
FilePathsBase.TestPaths
FilePathsBase.TestPaths.PathSet
```
