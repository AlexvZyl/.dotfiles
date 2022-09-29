# TestEnv

[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)


This is a 1-function package: `TestEnv.activate`.
It lets you activate the test enviroment from a given package.
Just like `Pkg.activate` lets you activate it's main enviroment.


Consider for example **ChainRules.jl** has as a test-only dependency of **ChainRulesTestUtils.jl**,
not a main dependency

```julia
pkg> activate ~/.julia/dev/ChainRules

julia> using TestEnv;

julia> TestEnv.activate();

julia> using ChainRulesTestUtils
```

Use `Pkg.activate` to re-activate the previous environment, e.g. `Pkg.activate("~/.julia/dev/ChainRules")`.

You can also pass in the name of a package, to activate that package and it's test dependencies:
`TestEnv.activate("Javis")` for example would activate Javis.jl's test environment.

Finally you can pass in a function to run in this environment.
```julia
using TestEnv, ReTest
TestEnv.activate("Example") do
    retest()
end
```

## Where is the code?
The astute reader has probably notice that the default branch of this git repo is basically empty.
This is because we keep all the code in other branches.
One per minor release: `release-1.0`, `release-1.1` etc.
We do this because TestEnv.jl accesses a whole ton of interals of [Pkg](https://github.com/JuliaLang/Pkg.jl).
These internals change basically every single release.
Maintaining compatibility in a single branch for multiple julia versions leads to code that is a nightmare.
As such, we instead maintain 1 branch per julia minor version.
And we tag releases off that branch with major and minor versions matching the julia version supported, but with patch versions allowed to change freely.

 - [release-1.0](https://github.com/JuliaTesting/TestEnv.jl/tree/release-1.0) contains the code to support julia v1.0.x
 - [release-1.1](https://github.com/JuliaTesting/TestEnv.jl/tree/release-1.1) contains the code to support julia v1.1.x
 - [release-1.2](https://github.com/JuliaTesting/TestEnv.jl/tree/release-1.2) contains the code to support julia v1.2.x
 - [release-1.3](https://github.com/JuliaTesting/TestEnv.jl/tree/release-1.3) contains the code to support julia v1.3.x
 - [release-1.4](https://github.com/JuliaTesting/TestEnv.jl/tree/release-1.4) contains the code to support julia v1.4.x, v1.5.x, and v1.6.x
    - This was a rare goldern ages where the internals of Pkg did not change for almost a year.
 - [release-1.7](https://github.com/JuliaTesting/TestEnv.jl/tree/release-1.7) contains the code to support julia v1.7.x
 - [release-1.8](https://github.com/JuliaTesting/TestEnv.jl/tree/release-1.8) contains the code to support julia v1.8.x


**Do not make PRs against this COVER branch.**
Except to update this README.
Instead you probably want to PR a branch for some current version of Julia.

This is a bit weird for semver.
New features *can* be added in patch release, but they must be ported to all later branches, and patch releases must be made there also.
For the this reason: we *only* support the latest patch release of any branch.
Older ones may be yanked if they start causing issues for people.


## What should I put in my Project.toml `[compat]` section
If using this as a dependency of a package that supports many versions of julia you may wonder what to put in your Project.toml's [compat] section.
Do not fear, the package manager has your back.
If you put in your `[compat]` for `TestEnv=`: `1` or equivalently `1.0` or `1.0` or `1.0.0` or `^1`, or `^1.0` or `^1.0` or `^1.0.0`,
then the package manager is free to choose any compatible version `v` with `1.0.0 <= v < 2.0.0`.
It will thus chose the corret minor version of TestEnv that is compatible with the loaded version of Julia.

### See also:
 - [Discourse Release Announcement](https://discourse.julialang.org/t/ann-testenv-jl-activate-your-test-enviroment-so-you-can-use-your-test-dependencies/65739)
