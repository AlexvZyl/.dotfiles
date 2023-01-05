[![Travis Build Status](https://travis-ci.org/JuliaCollections/OrderedCollections.jl.svg?branch=master)](https://travis-ci.org/JuliaCollections/OrderedCollections.jl)
[![Appveyor Build Status](https://ci.appveyor.com/api/projects/status/5gw9xok4e58aixsv?svg=true)](https://ci.appveyor.com/project/kmsquire/datastructures-jl)
[![Test Coverage](https://codecov.io/github/JuliaCollections/OrderedCollections.jl/coverage.svg?branch=master)](https://codecov.io/github/JuliaCollections/OrderedCollections.jl?branch=master)
[![PkgEval.jl Status on Julia 0.7](http://pkg.julialang.org/badges/OrderedCollections_0.7.svg)](http://pkg.julialang.org/?pkg=OrderedCollections&ver=0.7)
[![Documentation](https://img.shields.io/badge/docs-latest-blue.svg)](https://juliacollections.github.io/OrderedCollections.jl/latest)

OrderedCollections.jl
=====================

This package implements OrderedDicts and OrderedSets, which are similar to containers in base Julia.
However, during iteration the Ordered* containers return items in the order in which they were added to the collection.
It also implements `LittleDict` which is a ordered dictionary, that is much faster than any other `AbstractDict` (ordered or not) for small collections.

This package was split out from [DataStructures.jl](https://github.com/JuliaCollections/DataStructures.jl).

Resources
---------

-   **Documentation**: https://juliacollections.github.io/OrderedCollections.jl/latest
