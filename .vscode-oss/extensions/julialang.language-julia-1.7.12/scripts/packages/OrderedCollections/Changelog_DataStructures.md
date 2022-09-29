
0.7.0 / 2017-09-02
==================

  * Drop support for Julia v0.5 (and update to v0.6/v0.7 syntax)
  * Add some missing things to docs (#317)
  * Remove additional v0.6 deprecations
  * Fix a "formal" ambiguity on 0.6+ and enable ambiguity tests
  * Remove Compat (not needed/used right now)
  * Move all tests to testsets

v0.6.1 / 2017-07-26
==================
  * Fix most of 0.7 depwarns

v0.6.0 / 2017-07-09
==================
  * Fix depwarn on 0.7
  * Update CI URLs to point to new caching infrastructure
  * Re-fix 0.6 depwarns

v0.5.3 / 2017-02-21
==================
  * Julia v0.6 depwarn, ambiguity, and other misc fixes
  * Fix 0.6 typealias depwarn
  * Fix 0.6 abstract type declaration depwarn
  * Fix 0.6 misc other depwarns

v0.5.2 / 2017-01-18
==================
  * Julia 0.6 fixes
  * Remove recently introduced TypeVars.
  * Don't allow failure on nightly

v0.5.1 / 2017-01-07
==================
  * Temporarily revert removal of HashDict (broke gadfly)

v0.5.0 / 2017-01-05
==================
  * Changed OrderedDict implementation to Jeff Bezanson's version (from Julia #10116)
  * Remove HashDict (no longer needed), refactor Dict-related classes
  * Added more Dict-related tests
  * Allow OrderedDicts to be sorted
  * Fix xor deprecations

v0.4.6 / 2016-07-28
==================
  * isdefined -> isassigned

v0.4.5 / 2016-07-28
==================
  * Fixes for Julia v0.5
     * Exception type updates for
     * Export complement if not available in Base
     * Fix ASCIIString, UTF8String -> String deprecations
     * Fix getfield deprecation
  * Add RTD badge to Readme

v0.4.4 / 2016-04-10
==================
  * rename files with underscores for consistency
  * OrderedDict: use type parameters for constructor, rather than as parameters
  * add various docstrings
  * Remove spaces between {} and () in function/constructor definitions

v0.4.3 / 2016-02-10
==================
  * Many deprecation warnings were deleted (https://github.com/JuliaLang/DataStructures.jl/pull/161)
  * Ordered sets now have indexing
  * Performance improvements to OrderedDict


v0.4.2 / 2016-01-13
==================

  * Fix OrderedDict constructors (with tests)
  * Dead code, tree.jl removal

v0.4.1 / 2015-12-29
===================

  * Updated Changelog
  * Merge pull request #156 from JuliaLang/kms/remove-v0.3-part2
  * Replace tuple_or_pair with Pair() or Pair{}
  * More thorough removal of v0.3 support
  * Updated Changelog.md

v0.4.1 / 2015-12-29
==================

  * More thorough removal of v0.3 support
  * Replace tuple_or_pair with Pair() or Pair{}

v0.4.0 / 2015-12-28
===================

  * Remove support for Julia 0.3

v0.3.14 / 2015-11-14
====================

  * OrderedDict:
    * Implement merge for OrderedDict
    * Serialize and deserialize
  * Remove invalid rst and align elements
  * Fix #34, implement `==` instead of `isequal` in places
  * Define ==(x::Nil, y::Nil) and ==(x::Cons, y::Cons)

v0.3.13 / 2015-09-18
====================

  * Julia v0.4 updates
    * Union() -> Union{}
    * 0.4 bindings deprecation
    * Add operator imports to fix deprecation warnings
  * Travis
    * Run tests on 0.3, 0.4, and nightly (0.5)
    * Enable osx
    * (Re)enable codecov
  * Add precompile directive
  * Switched setindex! to insert!
  * Fix Pair usage for OrderedDict

v0.3.11 / 2015-07-14
====================

  * Fix deprecated syntax in OrderedSet test
  * Updated README with extra DefaultDict examples
  * More formatting updates to README.rst
  * Remove syntax deprecation warnings on 0.4

v0.3.10 / 2015-06-29
====================

  * REQUIRE: bump Julia version to v0.3
  * Fix serialization ambiguity warnings

v0.3.9 / 2015-05-03
===================

  * Fix error on 0.4-dev, allow running tests without installing

v0.3.8 / 2015-04-18
===================

  * Add special OrderedDict deprection for Numbers
  * Fix warning about {A, B...}

v0.3.7 / 2015-04-17
===================

  * 0.4 Compat fixes
  * Implement nlargest and nsmallest

v0.3.6 / 2015-03-05
===================

  * Updated OrderedSet, OrderedDict tests
  * Update OrderedDict, OrderedSet constructors to take iterables
  * Use Julia 0.4 syntax
  * Added compat support for Julia v0.3
  * Rewrite README in rst format (instead of md)
  * Get coverage data generation back up for Coveralls
  * Update Travis to use Julia Language Support
  * use Base.warn_once() instead of warn()
  * Support v0.4 style association construction via Pair operator
  * Update syntax to avoid deprecation warnings on Julia 0.4
  * Consistent whitespace

v0.3.4 / 2014-10-14
===================

  * Fix #60
  * Update Dict construction to use new syntax
  * Fix signed/unsigned issue in hashindex
  * Modernize Travis, Pkg.test compat, coverage, badges

v0.3.2 / 2014-08-31
===================

  * Remove trailing whitespace
  * Add more constructors for Trie
  * Remove trailing whitespace

v0.3.1 / 2014-07-14
===================

  * Update README
  * Deprecate add\! in favor of push\!

v0.3.0 / 2014-06-10
===================

  * Bump REQUIRE to v0.3, for incompatible change in test_throws

v0.2.15 / 2014-06-10
====================

  * Revert "fix `@test_throw` warnings"

v0.2.14 / 2014-06-02
====================

  * Import serialize_type in hashdict.jl
  * Add some clarification on code examples
  * fix `@test_throw` warnings
  * use SVG logo for travis status
  * rename run_tests.jl to runtests.jl

v0.2.13 / 2014-05-08
====================

  * Revert "Remove unused code"
  * Fix broken tests

v0.2.12 / 2014-04-26
====================

  * Import Base.reverse
  * Inserted missing comma
  * Avoid stack overflow in length method. Use iterator in show method
  * Changed name from add_singleton! to push!
  * Update README.md

v0.2.11 / 2014-04-10
====================

  * Update README.md (closes #24)
  * Changed the name make_set to add_singleton
  * import serialize, deserialize
  * Clean up code. Follow Dict interface more closely.
  * Added working test of make_set!
  * Added make_set! to exports in DataStructures.jl
  * Changed length(s.parents) to length(s)
  * Added version of make_set! which automatically chooses the new element as the next available one
  * Added ! to the name of the make_set function, since it modifies the structure
  * Added make_set to add single element as a new disjoint set, with its parent equal to itself
  * Implemented list iterator functions
  * add list and binary tree. closes #17

v0.2.10 / 2014-03-02
====================

  * Revert "Update REQUIRE to julia v0.3"

v0.2.9 / 2014-02-26
===================

  * Update REQUIRE to julia v0.3
  * Update README.md
  * Fix travis config. Enable testing with releases.
  * Change Travis badge url to JuliaLang
  * README.md: OrderedDefaultDict -> DefaultOrderedDict
  * fix C++ template syntax in README
  * Added/updated various dictionary, set variants
  * update travis.yml (disable apt-get upgrade)
  * add classified counters
  * add classified collections

v0.2.5 / 2013-10-08
===================

  * improved benchmark scripts

0.2.4 / 2013-07-27
==================

  * add travis logo to readme
  * add travis.yml
  * use run_tests.jl in the place of test/test_all.jl
  * Added 1 missing API call to the documentation

0.2.3 / 2013-04-21
==================

  * export in_same_set

0.2.0 / 2013-04-15
==================

  * add julia version requirement
  * Test ==> Base.Test & add test_all.jl
  * add empty REQUIRE file
  * Update README.md
  * add license
  * add readme
  * improved interface and added test
  * renamed to DataStructures
  * add stack and queue (tested)
  * add Dequeue (tested)
  * Initial commit
