module CompatIterators
# Defining this module with the name `CompatIterators` and define
# `const Iterators = CompatIterators` at the end of this file so that
#
#     julia> using Compat.Iterators
#
#     julia> Iterators
#     Base.Iterators
#
#     julia> takewhile
#     takewhile (generic function with 1 method)
#
# works without conflict in identifiers in all Julia versions.  Users
# still need to explicitly import `Compat.Iterators` via `using
# Compat: Iterators` to use, e.g., `Iterators.map` before Julia 1.6.
# This is the case with and without the `CompatIterators` hack.

using Base: SizeUnknown

# We normally use `Base.f(...) = ...` style for overloading.  However,
# we use `import Base: f` style here to make synchronizing the code
# with `Base` easier.
import Base: IteratorEltype, IteratorSize, eltype, iterate

# Import exported APIs
for n in names(Base.Iterators)
    n === :Iterators && continue
    @eval begin
        using Base.Iterators: $n
        export $n
    end
end

# Import unexported public APIs
using Base.Iterators: filter

# https://github.com/JuliaLang/julia/pull/33437
if VERSION < v"1.4.0-DEV.291"  # 5f013d82f92026f7dfbe4234f283658beb1f8a2a
    export takewhile, dropwhile

    # takewhile
    struct TakeWhile{I,P<:Function}
        pred::P
        xs::I
    end

    takewhile(pred,xs) = TakeWhile(pred,xs)

    function iterate(ibl::TakeWhile, itr...)
        y = iterate(ibl.xs,itr...)
        y === nothing && return nothing
        ibl.pred(y[1]) || return nothing
        y
    end

    IteratorSize(::Type{<:TakeWhile}) = SizeUnknown()
    eltype(::Type{TakeWhile{I,P}}) where {I,P} = eltype(I)
    IteratorEltype(::Type{TakeWhile{I,P}}) where {I,P} = IteratorEltype(I)

    # dropwhile
    struct DropWhile{I,P<:Function}
        pred::P
        xs::I
    end

    dropwhile(pred,itr) = DropWhile(pred,itr)

    iterate(ibl::DropWhile,itr) = iterate(ibl.xs, itr)
    function iterate(ibl::DropWhile)
        y = iterate(ibl.xs)
        while y !== nothing
            ibl.pred(y[1]) || break
            y = iterate(ibl.xs,y[2])
        end
        y
    end

    IteratorSize(::Type{<:DropWhile}) = SizeUnknown()
    eltype(::Type{DropWhile{I,P}}) where {I,P} = eltype(I)
    IteratorEltype(::Type{DropWhile{I,P}}) where {I,P} = IteratorEltype(I)
end

# https://github.com/JuliaLang/julia/pull/34352
if VERSION < v"1.6.0-DEV.258"  # 1f8b44204fafb1caabc6a1cd6ca39458a550e2fc
    map(f, args...) = Base.Generator(f, args...)
else
    using Base.Iterators: map
end

end  # module

const Iterators = CompatIterators
