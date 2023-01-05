```@meta
CurrentModule = StaticLint
```

# StaticLint

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://www.julia-vscode.org/StaticLint.jl/dev)
[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
![](https://github.com/julia-vscode/StaticLint.jl/workflows/Run%20CI%20on%20master/badge.svg)
[![codecov.io](http://codecov.io/github/julia-vscode/StaticLint.jl/coverage.svg?branch=master)](http://codecov.io/github/julia-vscode/StaticLint.jl?branch=master)


Static Code Analysis for Julia

## Installation and Usage
```julia
using Pkg
Pkg.add("StaticLint")
```
```julia
using StaticLint
```
**Documentation**: [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://www.julia-vscode.org/StaticLint.jl/dev)

## Description
This package supports LanguageServer.jl functionality broadly by:

1. linking the file tree of a project
2. marking scopes/namespaces within the syntax tree (ST)
3. marking variable bindings (functions, instances, etc.)
4. linking identifiers (i.e. variable names) to the relevant bindings
5. marking possible errors within the ST

Identifying and marking errors (5.) is, in general, dependent on steps 1-4. These are achieved through a single pass over the ST of a project. A pass over a single `EXPR` is achieved through calling a `State` object on the ST. This `State` requires an `AbstractServer` that determines how files within a project are loaded and makes packages available for loading.


### Passes
For a given experssion `x` this pass will:

* Handle import statements (`resolve_import`). This either explicitly imports variables into the current state (for statements such as `import/using SomeModule: binding1, binding2`) or makes the exported bindings of a modules available more generally (e.g. `using SomeOtherModule`). The availability of includable packages is handled by the `getsymbolserver` function called on the `state.server`.
* Determine whether `x` introduces a new variable. `mark_bindings!` performs this and may mark bindings for child nodes of `x` (e.g. when called on an expression that defines a `Function` this will mark the arguments of the signature as introducing bindings.)
* Adds any binding associated with `x` to the variable list of the current scope (`add_binding`).
* Handles global variables (`mark_globals`).
* Special handling for macros introducing new bindings as necessary, at the moment limited to `deprecate`, `enum`, `goto`, `label`, and `nospecialize`.
* Adds new scopes for the interior of `x` as needed (`scopes`).
* Resolves references for identifiers (i.e. a variable name), macro name, keywords in function signatures and dotted names (e.g. `A.B.c`). A name is first checked against bindings introduced within a scope then against exported variables of modules loaded into the scope. If this fails to resolve the name this is repeated for the parent scope. References that fail to resolve at this point, and are within a delayed scope (i.e. within a function) are added to a list to be resolved later.
* If `x` is a call to `include(path_expr)` attempt to resolve `path_expr` to a loadable file from `state.server` and pass across the files ST (`followinclude`).
* Traverse across child nodes of `x` (`traverse`) in execution order. This means, for example, that in the expression `a = b` we traverse `b` then `a` (ignoring the operator).

### Server
As mentioned, an `AbstractServer` is required to hold files within a project and provide access to user installed packages. An implementation must support the following functions:

`StaticLint.hasfile(server, path)::Bool` : Does the server have a file matching the name `path`.

`StaticLint.getfile(server, path)::AbstractFile` : Retrieves the file `path` - assumes the server has the file.

`StaticLint.setfile(server, path, file)::AbstractFile` : Stores `file` in the server under the name `path`, returning the file.

`StaticLint.canloadfile(server, path)::Bool` : Can the server load the file denoted by `path`, likely from an external source.

`StaticLint.loadfile(server, path)::AbstractFile` : Load the file at `path` from an external source (i.e. the hard drive).

`StaticLint.getsymbolserver(server)::Dict{String,SymbolServer.ModuleStore}` : Retrieve the server's depot of loadable packages.

An `AbstractFile` must support the following:

`StaticLint.getpath(file)` : Retrieve the path of a file.

`StaticLint.getroot(file)` : Retrieve the root of a file. The root is the main/first file in a file structure. For example the `StaticLint.jl` file is the root of all files (including itself) in `src/`.

`StaticLint.setroot(file, root)` : Set the root of a file.

`StaticLint.getcst(file)` : Retrieve the cst of a file.

`StaticLint.setcst(file, cst::CSTParser.EXPR)` : Set the cst of a file.

`StaticLint.getserver(file)` : Retrieve the server holding of a file.

`StaticLint.setserver(file, server::AbstractServer)` : Set the server of a file.

`StaticLint.semantic_pass(file, target = nothing(optional))` : Run a full pass on the ST of a project (i.e. ST of all linked files). It is expected that `file` is the root of the project.
