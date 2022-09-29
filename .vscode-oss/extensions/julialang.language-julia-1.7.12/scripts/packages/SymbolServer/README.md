# SymbolServer

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://www.julia-vscode.org/SymbolServer.jl/dev)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
![](https://github.com/julia-vscode/SymbolServer.jl/workflows/Run%20CI%20on%20master/badge.svg)
[![codecov.io](http://codecov.io/github/julia-vscode/SymbolServer.jl/coverage.svg?branch=master)](http://codecov.io/github/julia-vscode/SymbolServer.jl?branch=master)

SymbolServer is a helper package for LanguageServer.jl that provides information about internal and exported variables of packages (without loading them). A package's symbol information is initially loaded in an external process but then stored on disc for (quick loading) future use.

## Installation and Usage
```julia
using Pkg
Pkg.add("SymbolServer")
```
```julia
using SymbolServer
```
**Documentation**: [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://www.julia-vscode.org/SymbolServer.jl/dev)

Documentation for working with Julia environments is available [here](https://github.com/JuliaLang/Pkg.jl).

## API

```julia
SymbolServerInstance(path_to_depot, path_to_store)
```

Creates a new symbol server instance that works on a given Julia depot. This symbol server instance can be long lived, i.e. one can re-use it for different environments etc. If `path_to_store` is specified, cache files will be stored there, otherwise a standard location will be used.


```julia
getstore(ssi::SymbolServerInstance, environment_path::AbstractString)
```

Loads the symbols for the environment in `environment_path`. Returns a tuple, where the first element is a return status and the second element a payload. The status can be `:success` (in which case the second element is the new store), `:canceled` if another call to `getstore` was initiated before a previous one finished (with `nothing` as the payload), or `:failure` with the payload being the content of the error stream of the client process.

This function is long running and should typically be called in an `@async` block.
