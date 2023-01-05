```@meta
CurrentModule = SymbolServer
```

# SymbolServer

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://www.julia-vscode.org/SymbolServer.jl/dev)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
![](https://github.com/julia-vscode/SymbolServer.jl/workflows/Run%20CI%20on%20master/badge.svg)
[![codecov.io](http://codecov.io/github/julia-vscode/SymbolServer.jl/coverage.svg?branch=master)](http://codecov.io/github/julia-vscode/SymbolServer.jl?branch=master)

SymbolServer is a helper package for LanguageServer.jl that provides information about internal and exported variables of packages (without loading them). A package's symbol information is initially loaded in an external process but then stored on disc for (quick loading) future use.

## Installation and Usage

[IDEs](https://en.wikipedia.org/wiki/Integrated_development_environment) that exploit SymbolServer should install it automatically; if you are an IDE user, you probably don't need to manually install or update SymbolServer.

Developers and curious users can install it manually with
```julia
using Pkg
Pkg.add("SymbolServer")
```

Loading it is similar to any other Julia package,

```julia
using SymbolServer
```

## Server API

```julia
SymbolServerInstance(path_to_depot, path_to_store)
```

Creates a new symbol server instance that works on a given Julia depot. This symbol server instance can be long lived, i.e. one can re-use it for different environments etc. If `path_to_store` is specified, cache files will be stored there, otherwise a standard location will be used.

```julia
getstore(ssi::SymbolServerInstance, environment_path::AbstractString)
```

Loads the symbols for the environment in `environment_path`. Returns a tuple, where the first element is a return status and the second element a payload. The status can be `:success` (in which case the second element is the new store), `:canceled` if another call to `getstore` was initiated before a previous one finished (with `nothing` as the payload), or `:failure` with the payload being the content of the error stream of the client process.

This function is long running and should typically be called in an `@async` block.

## Indexing API

When a new environment is encountered, this environment must be indexed.
Indexing can be run manually with the following:

```julia
using SymbolServer
using Packages,You,Want,To,Index
env = SymbolServer.getenvtree() # Create a tree of all modules within the current session, including submodules
@time SymbolServer.symbols(env) # index everything
```

The last line performs indexing on the complete set of modules loaded into your session.
To perform indexing on a single module,

```julia
@time SymbolServer.symbols(env, SomeModule) # index a single module
```
