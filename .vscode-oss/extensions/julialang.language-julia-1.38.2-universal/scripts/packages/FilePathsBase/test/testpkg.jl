module TestPkg

using FilePathsBase

import Base: ==

__init__() = FilePathsBase.register(TestPath)

# Warning: We only expect this test to work on posix systems.

struct TestPath <: AbstractPath
    segments::Tuple{Vararg{String}}
    root::String
    drive::String
    separator::String
end

TestPath() = TestPath(tuple(), "", "test:", ";")

function Base.tryparse(::Type{TestPath}, str::AbstractString)
    startswith(str, "test:") || return nothing
    str = String(str)
    drive = "test:"
    str = str[6:end]

    isempty(str) && return TestPath(tuple("."), "", drive)

    tokenized = split(str, ";")
    root = isempty(tokenized[1]) ? ";" : ""

    return TestPath(tuple(map(String, filter!(!isempty, tokenized))...), root, drive, ";")
end

function test2posix(fp::TestPath)
    return PosixPath(fp.segments, isempty(fp.root) ? "" : "/")
end

function posix2test(fp::PosixPath)
    return TestPath(fp.segments, isempty(fp.root) ? "" : ";", "test:", ";")
end

# We're going to implement most of the posix API, but this won't make sense for many path types
FilePathsBase.exists(fp::TestPath) = exists(test2posix(fp))
Base.readlink(fp::TestPath) = posix2test(readlink(test2posix(fp)))
FilePathsBase.canonicalize(fp::TestPath) = posix2test(canonicalize(test2posix(fp)))
FilePathsBase.stat(fp::TestPath) = stat(test2posix(fp))
FilePathsBase.lstat(fp::TestPath) = lstat(test2posix(fp))
FilePathsBase.mode(fp::TestPath) = stat(fp).mode
Base.filesize(fp::TestPath) = stat(fp).size
FilePathsBase.created(fp::TestPath) = stat(fp).ctime
FilePathsBase.modified(fp::TestPath) = stat(fp).mtime
FilePathsBase.isdir(fp::TestPath) = isdir(mode(fp))
Base.isfile(fp::TestPath) = isfile(mode(fp))
Base.islink(fp::TestPath) = islink(lstat(fp).mode)
Base.issocket(fp::TestPath) = issocket(mode(fp))
Base.isfifo(fp::TestPath) = issocket(mode(fp))
Base.ischardev(fp::TestPath) = ischardev(mode(fp))
Base.isblockdev(fp::TestPath) = isblockdev(mode(fp))
Base.ismount(fp::TestPath) = ismount(test2posix(fp))
FilePathsBase.isexecutable(fp::TestPath) = isexecutable(test2posix(fp))
Base.iswritable(fp::TestPath) = iswritable(test2posix(fp))
Base.isreadable(fp::TestPath) = isreadable(test2posix(fp))
Base.cd(fp::TestPath) = cd(test2posix(fp))
Base.cd(f::Function, fp::TestPath) = cd(f, test2posix(fp))
Base.mkdir(fp::TestPath; kwargs...) = posix2test(mkdir(test2posix(fp); kwargs...))
Base.symlink(src::TestPath, dest::TestPath; kwargs...) = symlink(test2posix(src), test2posix(dest); kwargs...)
Base.rm(fp::TestPath; kwargs...) = rm(test2posix(fp); kwargs...)
Base.read(fp::TestPath) = read(test2posix(fp))
Base.write(fp::TestPath, x) = write(test2posix(fp), x)
Base.chown(fp::TestPath, args...; kwargs...) = chown(test2posix(fp), args...; kwargs...)
Base.chmod(fp::TestPath, args...; kwargs...) = chmod(test2posix(fp), args...; kwargs...)

function Base.readdir(fp::TestPath; join=false, sort=true)
    p = test2posix(fp)
    @static if VERSION < v"1.4"
        return readdir(p)
    else
        results = readdir(p; join=join, sort=sort)
        join || return results
        # Awkward wrapper that converts the readdir output back to a TestPath string.
        return string.(posix2test.(parse.(PosixPath, results)))
    end
end

end
