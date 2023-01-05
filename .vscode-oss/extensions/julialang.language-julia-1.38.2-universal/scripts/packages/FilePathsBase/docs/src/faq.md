# FAQ

Here we have a growing list of common technical and design questions folks have raised in the past.
If you feel like something is missing, please open an issue or pull request to add it.

**Q. Should I depend on FilePathsBase.jl and FilePaths.jl?**

A. FilePathsBase.jl is a lightweight dependency for packages who need to operate on `AbstractPath` types and don't need to interact with other packages (e.g., Glob.jl, URIParser.jl, FileIO.jl).
FilePaths.jl extends FilePathsBase.jl to improve package interop across the Julia ecosystem, at the cost of extra dependencies.
In general, FilePathsBase.jl should be used for general (low level) packages. While scripts and application-level packages should use FilePaths.jl.

**Q. What's wrong with strings?**

A. In many cases, nothing.
For local filesystem paths, there's often no functional difference between using an `AbstractPath` and a `String`.
Some cases where the path type distinction is useful include:

- Path specific operations (e.g., `join`, `/`, `==`)
- Dispatch on paths vs strings (e.g., `project(name::String) = project(DEFAULT_ROOT / name)`)

See [design section](@ref design_header) for more details on the advantages of path types over strings.

**Q. Why is `AbstractPath` not a subtype of `AbstractString`?**

A. Initially, we made `AbstractPath` a subtype of `AbstractString`, but falling back to string operations often didn't make sense (e.g., `ascii(::AbstractPath)`, `chomp(::AbstractPath)`, `match(::Regex, ::AbstractPath)`, `parse(::Type{Float64}, ::AbstractPath)`).
Having a distinct path type results in fewer confusing error messages and more explicit code (via type conversions). See [issue #15](https://github.com/rofinn/FilePathsBase.jl/issues/15) for more info on why we dropped string subtyping.

**Q. Why don't you concatenate paths with `*`?**

A. By using `/` for path concatenation (`joinpath`), we can continue to support string concatenation with `*`:

```julia
julia> cwd() / "src" / "FilePathsBase" * ".jl"
p"/Users/rory/repos/FilePathsBase.jl/src/FilePathsBase.jl
```

**Q. How do I write code that works with strings and paths?**

A. FilePathsBase.jl intentionally provides aliases for `Base.Filesystem` functions, so you can perform base filesystem operations on strings and paths interchangeable.
If something is missing please open an issue or pull request.
Here are some more concrete tips to help you write generic code:
- Don't [overly constrain](https://white.ucc.asn.au/2020/04/19/Julia-Antipatterns.html#over-constraining-argument-types) your argument types.
- Avoid manual string manipulations (e.g., `match`, `replace`).
- Stick to the overlapping base filesystem aliases (e.g., `joinpath` vs `/`, `normpath` vs `normalize`).

NOTE: The first 2 points are just general best practices independent of path types.
Unfortunately, the last point is a result of the `Base.Filesystem` API (could change if FilePathsBase.jl becomes a stdlib).

See the usage guide for examples.

**Q: FilePathsBase doesn't work with package X?**

A: In many cases, filepath types and strings are interchangable, but if a specific package constrains the argument type (e.g., `AbstractString`, `String`) then you'll get a `MethodError`.
There are a few solutions to this problem.

1. Loosen the argument type constraint in the given package.
2. Add a separate dispatch for `AbstractPath` and add a dependency on FilePathsBase.jl.
3. For very general/lightweight packages we can add the dependency to FilePaths.jl and extend the offending function there.
4. Manually convert your path to a string before calling into the package.
You may need to parse any returned paths to back to a filepath type if necessary.

NOTE: For larger packages, FilePaths.jl provides an `@convert` macro which will handle generating appropriate conversion methods for you.
