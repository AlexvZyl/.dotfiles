# FilePathsBase.jl

[![Build Status](https://github.com/rofinn/FilePathsBase.jl/workflows/CI/badge.svg)](https://github.com/rofinn/FilePathsBase.jl/actions)
[![codecov.io](https://codecov.io/github/rofinn/FilePathsBase.jl/coverage.svg?branch=master)](https://codecov.io/rofinn/FilePathsBase.jl?branch=master)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://rofinn.github.io/FilePathsBase.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://rofinn.github.io/FilePathsBase.jl/dev)

FilePathsBase.jl provides a type based approach to working with filesystem paths in julia.

## Intallation

FilePathsBase.jl is registered, so you can to use `Pkg.add` to install it.
```julia
julia> Pkg.add("FilePathsBase")
```

## Getting Started

Here are some common operations that you may want to perform with file paths.

```julia
#=
NOTE: We're loading our `/` operator for path concatenation into the currect scope, but non-path division operations will still fallback to the base behaviour.
=#
julia> using FilePathsBase; using FilePathsBase: /

julia> cwd()
p"/Users/rory/repos/FilePathsBase.jl"

julia> walkpath(cwd() / "docs") |> collect
23-element Array{Any,1}:
 p"/Users/rory/repos/FilePathsBase.jl/docs/.DS_Store"
 p"/Users/rory/repos/FilePathsBase.jl/docs/Manifest.toml"
 p"/Users/rory/repos/FilePathsBase.jl/docs/Project.toml"
 p"/Users/rory/repos/FilePathsBase.jl/docs/build"
 p"/Users/rory/repos/FilePathsBase.jl/docs/build/api.html"
 p"/Users/rory/repos/FilePathsBase.jl/docs/build/assets"
 p"/Users/rory/repos/FilePathsBase.jl/docs/build/assets/arrow.svg"
 p"/Users/rory/repos/FilePathsBase.jl/docs/build/assets/documenter.css"
 ...

julia> stat(p"docs/src/index.md")
Status(
  device = 16777223,
  inode = 32240108,
  mode = -rw-r--r--,
  nlink = 1,
  uid = 501 (rory),
  gid = 20 (staff),
  rdev = 0,
  size = 2028 (2.0K),
  blksize = 4096 (4.0K),
  blocks = 8,
  mtime = 2020-04-20T17:20:38.612,
  ctime = 2020-04-20T17:20:38.612,
)

julia> relative(p"docs/src/index.md", p"src/")
p"../docs/src/index.md"

julia> normalize(p"src/../docs/src/index.md")
p"docs/src/index.md"

julia> absolute(p"docs/src/index.md")
p"/Users/rory/repos/FilePathsBase.jl/docs/src/index.md"

julia> islink(p"docs/src/index.md")
true

julia> canonicalize(p"docs/src/index.md")
p"/Users/rory/repos/FilePathsBase.jl/README.md"

julia> parents(p"./docs/src")
2-element Array{PosixPath,1}:
 p"."
 p"./docs"

julia> parents(absolute(p"./docs/src"))
6-element Array{PosixPath,1}:
 p"/"
 p"/Users"
 p"/Users/rory"
 p"/Users/rory/repos"
 p"/Users/rory/repos/FilePathsBase.jl"
 p"/Users/rory/repos/FilePathsBase.jl/docs"

julia> absolute(p"./docs/src")[1:end-1]
("Users", "rory", "repos", "FilePathsBase.jl", "docs")

julia> tmpfp = mktempdir(SystemPath)
p"/var/folders/vz/zx_0gsp9291dhv049t_nx37r0000gn/T/jl_1GCBFT"

julia> sync(p"/Users/rory/repos/FilePathsBase.jl/docs", tmpfp / "docs")
p"/var/folders/vz/zx_0gsp9291dhv049t_nx37r0000gn/T/jl_1GCBFT/docs"

julia> exists(tmpfp / "docs" / "make.jl")
true

julia> m = mode(tmpfp / "docs" / "make.jl")
Mode("-rw-r--r--")

julia> m - readable(:ALL)
Mode("--w-------")

julia> m + executable(:ALL)
Mode("-rwxr-xr-x")

julia> chmod(tmpfp / "docs" / "make.jl", "+x")
"/var/folders/vz/zx_0gsp9291dhv049t_nx37r0000gn/T/jl_1GCBFT/docs/make.jl"

julia> mode(tmpfp / "docs" / "make.jl")
Mode("-rwxr-xr-x")

# Count LOC
julia> mapreduce(+, walkpath(cwd() / "src")) do x
           extension(x) == "jl" ? count("\n", read(x, String)) : 0
       end
3020

# Concatenate multiple files.
julia> str = mapreduce(*, walkpath(tmpfp / "docs" / "src")) do x
           read(x, String)
       end
"# API\n\nAll the standard methods for working with paths in base julia exist in the FilePathsBase.jl. The following describes the rough mapping of method names. Use `?` at the REPL to get the documentation and arguments as they may be different than the base implementations.\n\n..."

# Could also write the result to a file with `write(newfile, str)`)

julia> rm(tmpfp; recursive=true)

julia> exists(tmpfp)
false

# Loading code from paths (e.g., S3Path)
julia> FilePathsBase.@__INCLUDE__()

julia> include(p"test/testpkg.jl")
Main.TestPkg
```
