module Compat

import Dates
using Dates: Period, CompoundPeriod

import LinearAlgebra
using LinearAlgebra: Adjoint, Diagonal, Transpose, UniformScaling, RealHermSymComplexHerm, BLAS

include("compatmacro.jl")

# NOTE these `@inline` and `@noinline` definitions overwrite the definitions implicitly
# imported from Base and so should happen before any usages of them within this module

# https://github.com/JuliaLang/julia/pull/41312: `@inline`/`@noinline` annotations within a function body
@static if !hasmethod(getfield(Base, Symbol("@inline")), (LineNumberNode,Module))
    macro inline()   Expr(:meta, :inline)   end
    macro noinline() Expr(:meta, :noinline) end
end

# https://github.com/JuliaLang/julia/pull/41328: callsite annotations of inlining
@static if !isdefined(Base, :annotate_meta_def_or_block)
    macro inline(ex)   annotate_meta_def_or_nothing(ex, :inline)   end
    macro noinline(ex) annotate_meta_def_or_nothing(ex, :noinline) end
    function annotate_meta_def_or_nothing(@nospecialize(ex), meta::Symbol)
        inner = unwrap_macrocalls(ex)
        if is_function_def(inner)
            # annotation on a definition
            return esc(Base.pushmeta!(ex, meta))
        else
            # do nothing
            return esc(ex)
        end
    end
    unwrap_macrocalls(@nospecialize(x)) = x
    function unwrap_macrocalls(ex::Expr)
        inner = ex
        while inner.head === :macrocall
            inner = inner.args[end]::Expr
        end
        return inner
    end
    is_function_def(@nospecialize(ex)) =
        return Meta.isexpr(ex, :function) || is_short_function_def(ex) || Meta.isexpr(ex, :->)
    function is_short_function_def(@nospecialize(ex))
        Meta.isexpr(ex, :(=)) || return false
        while length(ex.args) >= 1 && isa(ex.args[1], Expr)
            (ex.args[1].head === :call) && return true
            (ex.args[1].head === :where || ex.args[1].head === :(::)) || return false
            ex = ex.args[1]
        end
        return false
    end
end

# https://github.com/JuliaLang/julia/pull/29440
if VERSION < v"1.1.0-DEV.389"
    Base.:(:)(I::CartesianIndex{N}, J::CartesianIndex{N}) where N =
        CartesianIndices(map((i,j) -> i:j, Tuple(I), Tuple(J)))
end

# https://github.com/JuliaLang/julia/pull/29442
if VERSION < v"1.1.0-DEV.403"
    Base.oneunit(::CartesianIndex{N}) where {N} = oneunit(CartesianIndex{N})
    Base.oneunit(::Type{CartesianIndex{N}}) where {N} = CartesianIndex(ntuple(x -> 1, Val(N)))
end

# https://github.com/JuliaLang/julia/pull/30268
if VERSION < v"1.1.0-DEV.811"
    Base.get(A::AbstractArray, I::CartesianIndex, default) = get(A, I.I, default)
end

# https://github.com/JuliaLang/julia/pull/29679
if VERSION < v"1.1.0-DEV.472"
    export isnothing
    isnothing(::Any) = false
    isnothing(::Nothing) = true
end

# https://github.com/JuliaLang/julia/pull/29749
if VERSION < v"1.1.0-DEV.792"
    export eachrow, eachcol, eachslice
    eachrow(A::AbstractVecOrMat) = (view(A, i, :) for i in axes(A, 1))
    eachcol(A::AbstractVecOrMat) = (view(A, :, i) for i in axes(A, 2))
    @inline function eachslice(A::AbstractArray; dims)
        length(dims) == 1 || throw(ArgumentError("only single dimensions are supported"))
        dim = first(dims)
        dim <= ndims(A) || throw(DimensionMismatch("A doesn't have $dim dimensions"))
        idx1, idx2 = ntuple(d->(:), dim-1), ntuple(d->(:), ndims(A)-dim)
        return (view(A, idx1..., i, idx2...) for i in axes(A, dim))
    end
end

function rangeargcheck(;step=nothing, length=nothing, kwargs...)
    if step===nothing && length===nothing
        throw(ArgumentError("At least one of `length` or `step` must be specified"))
    end
end

if VERSION < v"1.1.0-DEV.506"
    function Base.range(start, stop; kwargs...)
        rangeargcheck(;kwargs...)
        range(start; stop=stop, kwargs...)
    end
end

# https://github.com/JuliaLang/julia/pull/30496
if VERSION < v"1.2.0-DEV.272"
    Base.@pure hasfield(::Type{T}, name::Symbol) where T =
        Base.fieldindex(T, name, false) > 0
    export hasfield
    hasproperty(x, s::Symbol) = s in propertynames(x)
    export hasproperty
end

if VERSION < v"1.3.0-DEV.349"
    Base.findfirst(ch::AbstractChar, string::AbstractString) = findfirst(==(ch), string)
    Base.findnext(ch::AbstractChar, string::AbstractString, ind::Integer) =
        findnext(==(ch), string, ind)
    Base.findlast(ch::AbstractChar, string::AbstractString) = findlast(==(ch), string)
    Base.findprev(ch::AbstractChar, string::AbstractString, ind::Integer) =
        findprev(==(ch), string, ind)
end

# https://github.com/JuliaLang/julia/pull/29259
if VERSION < v"1.1.0-DEV.594"
    Base.merge(a::NamedTuple, b::NamedTuple, cs::NamedTuple...) = merge(merge(a, b), cs...)
    Base.merge(a::NamedTuple) = a
end

# https://github.com/JuliaLang/julia/pull/33129
if VERSION < v"1.4.0-DEV.142"
    export only

    Base.@propagate_inbounds function only(x)
        i = iterate(x)
        @boundscheck if i === nothing
            throw(ArgumentError("Collection is empty, must contain exactly 1 element"))
        end
        (ret, state) = i
        @boundscheck if iterate(x, state) !== nothing
            throw(ArgumentError("Collection has multiple elements, must contain exactly 1 element"))
        end
        return ret
    end

    # Collections of known size
    only(x::Ref) = x[]
    only(x::Number) = x
    only(x::Char) = x
    only(x::Tuple{Any}) = x[1]
    only(x::Tuple) = throw(
        ArgumentError("Tuple contains $(length(x)) elements, must contain exactly 1 element")
    )
    only(a::AbstractArray{<:Any, 0}) = @inbounds return a[]
    only(x::NamedTuple{<:Any, <:Tuple{Any}}) = first(x)
    only(x::NamedTuple) = throw(
        ArgumentError("NamedTuple contains $(length(x)) elements, must contain exactly 1 element")
    )
end

# https://github.com/JuliaLang/julia/pull/32628
if VERSION < v"1.3.0-alpha.8"
    Base.mod(i::Integer, r::Base.OneTo) = mod1(i, last(r))
    Base.mod(i::Integer, r::AbstractUnitRange{<:Integer}) = mod(i-first(r), length(r)) + first(r)
end

# https://github.com/JuliaLang/julia/pull/32739
# This omits special methods for more exotic matrix types, Triangular and worse.
if VERSION < v"1.4.0-DEV.92" # 2425ae760fb5151c5c7dd0554e87c5fc9e24de73

    # stdlib/LinearAlgebra/src/generic.jl
    LinearAlgebra.dot(x, A, y) = LinearAlgebra.dot(x, A*y) # generic fallback

    function LinearAlgebra.dot(x::AbstractVector, A::AbstractMatrix, y::AbstractVector)
        (axes(x)..., axes(y)...) == axes(A) || throw(DimensionMismatch())
        T = typeof(LinearAlgebra.dot(first(x), first(A), first(y)))
        s = zero(T)
        i₁ = first(eachindex(x))
        x₁ = first(x)
        @inbounds for j in eachindex(y)
            yj = y[j]
            if !iszero(yj)
                temp = zero(adjoint(A[i₁,j]) * x₁)
                @simd for i in eachindex(x)
                    temp += adjoint(A[i,j]) * x[i]
                end
                s += LinearAlgebra.dot(temp, yj)
            end
        end
        return s
    end
    LinearAlgebra.dot(x::AbstractVector, adjA::Adjoint, y::AbstractVector) =
         adjoint(LinearAlgebra.dot(y, adjA.parent, x))
    LinearAlgebra.dot(x::AbstractVector, transA::Transpose{<:Real}, y::AbstractVector) =
        adjoint(LinearAlgebra.dot(y, transA.parent, x))

    # stdlib/LinearAlgebra/src/diagonal.jl
    function LinearAlgebra.dot(x::AbstractVector, D::Diagonal, y::AbstractVector)
        mapreduce(t -> LinearAlgebra.dot(t[1], t[2], t[3]), +, zip(x, D.diag, y))
    end

    # stdlib/LinearAlgebra/src/symmetric.jl
    function LinearAlgebra.dot(x::AbstractVector, A::RealHermSymComplexHerm, y::AbstractVector)
        require_one_based_indexing(x, y)
        (length(x) == length(y) == size(A, 1)) || throw(DimensionMismatch())
        data = A.data
        r = zero(eltype(x)) * zero(eltype(A)) * zero(eltype(y))
        if A.uplo == 'U'
            @inbounds for j = 1:length(y)
                r += LinearAlgebra.dot(x[j], real(data[j,j]), y[j])
                @simd for i = 1:j-1
                    Aij = data[i,j]
                    r += LinearAlgebra.dot(x[i], Aij, y[j]) +
                        LinearAlgebra.dot(x[j], adjoint(Aij), y[i])
                end
            end
        else # A.uplo == 'L'
            @inbounds for j = 1:length(y)
                r += LinearAlgebra.dot(x[j], real(data[j,j]), y[j])
                @simd for i = j+1:length(y)
                    Aij = data[i,j]
                    r += LinearAlgebra.dot(x[i], Aij, y[j]) +
                        LinearAlgebra.dot(x[j], adjoint(Aij), y[i])
                end
            end
        end
        return r
    end

    # stdlib/LinearAlgebra/src/uniformscaling.jl
    LinearAlgebra.dot(x::AbstractVector, J::UniformScaling, y::AbstractVector) =
        LinearAlgebra.dot(x, J.λ, y)
    LinearAlgebra.dot(x::AbstractVector, a::Number, y::AbstractVector) =
        sum(t -> LinearAlgebra.dot(t[1], a, t[2]), zip(x, y))
    LinearAlgebra.dot(x::AbstractVector, a::Union{Real,Complex}, y::AbstractVector) =
        a*LinearAlgebra.dot(x, y)
end

# https://github.com/JuliaLang/julia/pull/30630
if VERSION < v"1.2.0-DEV.125" # 1da48c2e4028c1514ed45688be727efbef1db884
    require_one_based_indexing(A...) = !Base.has_offset_axes(A...) || throw(ArgumentError(
        "offset arrays are not supported but got an array with index other than 1"))
# At present this is only used in Compat inside the above dot(x,A,y) functions, #32739
elseif VERSION < v"1.4.0-DEV.92"
    using Base: require_one_based_indexing
end

# https://github.com/JuliaLang/julia/pull/33568
if VERSION < v"1.4.0-DEV.329"
    Base.:∘(f, g, h...) = ∘(f ∘ g, h...)
end
# https://github.com/JuliaLang/julia/pull/34251
if VERSION < v"1.5.0-DEV.56"
    Base.:∘(f) = f
end

# https://github.com/JuliaLang/julia/pull/33128
if VERSION < v"1.4.0-DEV.397"
    export pkgdir
    function pkgdir(m::Module)
        rootmodule = Base.moduleroot(m)
        path = pathof(rootmodule)
        path === nothing && return nothing
        return dirname(dirname(path))
    end
end

# https://github.com/JuliaLang/julia/pull/33736/
if VERSION < v"1.4.0-DEV.493"
    Base.Order.ReverseOrdering() = Base.Order.ReverseOrdering(Base.Order.Forward)
end

# https://github.com/JuliaLang/julia/pull/32968
if VERSION < v"1.4.0-DEV.551"
    Base.filter(f, xs::Tuple) = Base.afoldl((ys, x) -> f(x) ? (ys..., x) : ys, (), xs...)
    Base.filter(f, t::Base.Any16) = Tuple(filter(f, collect(t)))
end

# https://github.com/JuliaLang/julia/pull/34652
if VERSION < v"1.5.0-DEV.247"
    export ismutable
    ismutable(@nospecialize(x)) = (Base.@_pure_meta; typeof(x).mutable)
end

# https://github.com/JuliaLang/julia/pull/28761
export uuid5
if VERSION < v"1.1.0-DEV.326"
    import SHA
    import UUIDs: UUID
    function uuid5(ns::UUID, name::String)
        nsbytes = zeros(UInt8, 16)
        nsv = ns.value
        for idx in Base.OneTo(16)
            nsbytes[idx] = nsv >> 120
            nsv = nsv << 8
        end
        hash_result = SHA.sha1(append!(nsbytes, convert(Vector{UInt8}, codeunits(unescape_string(name)))))
        # set version number to 5
        hash_result[7] = (hash_result[7] & 0x0F) | (0x50)
        hash_result[9] = (hash_result[9] & 0x3F) | (0x80)
        v = zero(UInt128)
        #use only the first 16 bytes of the SHA1 hash
        for idx in Base.OneTo(16)
            v = (v << 0x08) | hash_result[idx]
        end
        return UUID(v)
    end
else
    using UUIDs: uuid5
end

# https://github.com/JuliaLang/julia/pull/34773
if VERSION < v"1.5.0-DEV.301"
    Base.zero(::AbstractIrrational) = false
    Base.zero(::Type{<:AbstractIrrational}) = false

    Base.one(::AbstractIrrational) = true
    Base.one(::Type{<:AbstractIrrational}) = true
end

# https://github.com/JuliaLang/julia/pull/32753
if VERSION < v"1.4.0-DEV.513"
    function evalpoly(x, p::Tuple)
        if @generated
            N = length(p.parameters)
            ex = :(p[end])
            for i in N-1:-1:1
                ex = :(muladd(x, $ex, p[$i]))
            end
            ex
        else
            _evalpoly(x, p)
        end
    end

    evalpoly(x, p::AbstractVector) = _evalpoly(x, p)

    function _evalpoly(x, p)
        N = length(p)
        ex = p[end]
        for i in N-1:-1:1
            ex = muladd(x, ex, p[i])
        end
        ex
    end

    function evalpoly(z::Complex, p::Tuple)
        if @generated
            N = length(p.parameters)
            a = :(p[end])
            b = :(p[end-1])
            as = []
            for i in N-2:-1:1
                ai = Symbol("a", i)
                push!(as, :($ai = $a))
                a = :(muladd(r, $ai, $b))
                b = :(muladd(-s, $ai, p[$i]))
            end
            ai = :a0
            push!(as, :($ai = $a))
            C = Expr(:block,
            :(x = real(z)),
            :(y = imag(z)),
            :(r = x + x),
            :(s = muladd(x, x, y*y)),
            as...,
            :(muladd($ai, z, $b)))
        else
            _evalpoly(z, p)
        end
    end
    evalpoly(z::Complex, p::Tuple{<:Any}) = p[1]

    evalpoly(z::Complex, p::AbstractVector) = _evalpoly(z, p)

    function _evalpoly(z::Complex, p)
        length(p) == 1 && return p[1]
        N = length(p)
        a = p[end]
        b = p[end-1]

        x = real(z)
        y = imag(z)
        r = 2x
        s = muladd(x, x, y*y)
        for i in N-2:-1:1
            ai = a
            a = muladd(r, ai, b)
            b = muladd(-s, ai, p[i])
        end
        ai = a
        muladd(ai, z, b)
    end
    export evalpoly
end

# https://github.com/JuliaLang/julia/pull/35304
if VERSION < v"1.5.0-DEV.574"
    Base.similar(A::PermutedDimsArray, T::Type, dims::Base.Dims) = similar(parent(A), T, dims)
end

# https://github.com/JuliaLang/julia/pull/34548
if VERSION < v"1.5.0-DEV.314"
    macro NamedTuple(ex)
        Meta.isexpr(ex, :braces) || Meta.isexpr(ex, :block) ||
            throw(ArgumentError("@NamedTuple expects {...} or begin...end"))
        decls = filter(e -> !(e isa LineNumberNode), ex.args)
        all(e -> e isa Symbol || Meta.isexpr(e, :(::)), decls) ||
            throw(ArgumentError("@NamedTuple must contain a sequence of name or name::type expressions"))
        vars = [QuoteNode(e isa Symbol ? e : e.args[1]) for e in decls]
        types = [esc(e isa Symbol ? :Any : e.args[2]) for e in decls]
        return :(NamedTuple{($(vars...),), Tuple{$(types...)}})
    end

    export @NamedTuple
end

# https://github.com/JuliaLang/julia/pull/34296
if VERSION < v"1.5.0-DEV.182"
    export mergewith, mergewith!
    _asfunction(f::Function) = f
    _asfunction(f) = (args...) -> f(args...)
    mergewith(f, dicts...) = merge(_asfunction(f), dicts...)
    mergewith!(f, dicts...) = merge!(_asfunction(f), dicts...)
    mergewith(f) = (dicts...) -> mergewith(f, dicts...)
    mergewith!(f) = (dicts...) -> mergewith!(f, dicts...)
end

# https://github.com/JuliaLang/julia/pull/32003
if VERSION < v"1.4.0-DEV.29"
    hasfastin(::Type) = false
    hasfastin(::Union{Type{<:AbstractSet},Type{<:AbstractDict},Type{<:AbstractRange}}) = true
    hasfastin(x) = hasfastin(typeof(x))
else
    const hasfastin = Base.hasfastin
end

# https://github.com/JuliaLang/julia/pull/34427
if VERSION < v"1.5.0-DEV.124"
    const FASTIN_SET_THRESHOLD = 70

    function isdisjoint(l, r)
        function _isdisjoint(l, r)
            hasfastin(r) && return !any(in(r), l)
            hasfastin(l) && return !any(in(l), r)
            Base.haslength(r) && length(r) < FASTIN_SET_THRESHOLD &&
                return !any(in(r), l)
            return !any(in(Set(r)), l)
        end
        if Base.haslength(l) && Base.haslength(r) && length(r) < length(l)
            return _isdisjoint(r, l)
        end
        _isdisjoint(l, r)
    end

    export isdisjoint
end

# https://github.com/JuliaLang/julia/pull/35577
if VERSION < v"1.5.0-DEV.681"
    Base.union(r::Base.OneTo, s::Base.OneTo) = Base.OneTo(max(r.stop,s.stop))
end

# https://github.com/JuliaLang/julia/pull/35929
# and also https://github.com/JuliaLang/julia/pull/29135 -> Julia 1.5
if VERSION < v"1.5.0-rc1.13" || v"1.6.0-" < VERSION < v"1.6.0-DEV.323"

    # Compat.stride not Base.stride, so as not to overwrite the method, and not to create ambiguities:
    function stride(A::AbstractArray, k::Integer)
        st = strides(A)
        k ≤ ndims(A) && return st[k]
        return sum(st .* size(A))
    end
    stride(A,k) = Base.stride(A,k) # Fall-through for other methods.

    # These were first defined for Adjoint{...,StridedVector} etc in #29135
    Base.strides(A::Adjoint{<:Real, <:AbstractVector}) = (stride(A.parent, 2), stride(A.parent, 1))
    Base.strides(A::Transpose{<:Any, <:AbstractVector}) = (stride(A.parent, 2), stride(A.parent, 1))
    Base.strides(A::Adjoint{<:Real, <:AbstractMatrix}) = reverse(strides(A.parent))
    Base.strides(A::Transpose{<:Any, <:AbstractMatrix}) = reverse(strides(A.parent))
    Base.unsafe_convert(::Type{Ptr{T}}, A::Adjoint{<:Real, <:AbstractVecOrMat}) where {T} = Base.unsafe_convert(Ptr{T}, A.parent)
    Base.unsafe_convert(::Type{Ptr{T}}, A::Transpose{<:Any, <:AbstractVecOrMat}) where {T} = Base.unsafe_convert(Ptr{T}, A.parent)

    Base.elsize(::Type{<:Adjoint{<:Real, P}}) where {P<:AbstractVecOrMat} = Base.elsize(P)
    Base.elsize(::Type{<:Transpose{<:Any, P}}) where {P<:AbstractVecOrMat} = Base.elsize(P)

end

# https://github.com/JuliaLang/julia/pull/27516
if VERSION < v"1.2.0-DEV.77"
    import Test: @inferred
    using Core.Compiler: typesubtract

    macro inferred(allow, ex)
        _inferred(ex, __module__, allow)
    end

    function _inferred(ex, mod, allow = :(Union{}))
        if Meta.isexpr(ex, :ref)
            ex = Expr(:call, :getindex, ex.args...)
        end
        Meta.isexpr(ex, :call)|| error("@inferred requires a call expression")
        farg = ex.args[1]
        if isa(farg, Symbol) && first(string(farg)) == '.'
            farg = Symbol(string(farg)[2:end])
            ex = Expr(:call, GlobalRef(Base.Test, :_materialize_broadcasted),
                farg, ex.args[2:end]...)
        end
        Base.remove_linenums!(quote
            let
                allow = $(esc(allow))
                allow isa Type || throw(ArgumentError("@inferred requires a type as second argument"))
                $(if any(a->(Meta.isexpr(a, :kw) || Meta.isexpr(a, :parameters)), ex.args)
                    # Has keywords
                    args = gensym()
                    kwargs = gensym()
                    quote
                        $(esc(args)), $(esc(kwargs)), result = $(esc(Expr(:call, _args_and_call, ex.args[2:end]..., ex.args[1])))
                        inftypes = $(gen_call_with_extracted_types(mod, Base.return_types, :($(ex.args[1])($(args)...; $(kwargs)...))))
                    end
                else
                    # No keywords
                    quote
                        args = ($([esc(ex.args[i]) for i = 2:length(ex.args)]...),)
                        result = $(esc(ex.args[1]))(args...)
                        inftypes = Base.return_types($(esc(ex.args[1])), Base.typesof(args...))
                    end
                end)
                @assert length(inftypes) == 1
                rettype = result isa Type ? Type{result} : typeof(result)
                rettype <: allow || rettype == typesubtract(inftypes[1], allow) || error("return type $rettype does not match inferred return type $(inftypes[1])")
                result
            end
        end)
    end
    #export @inferred
end

# https://github.com/JuliaLang/julia/pull/36360
if VERSION < v"1.6.0-DEV.322" # b8110f8d1ec6349bee77efb5022621fdf50bd4a5

    function guess_vendor()
        # like determine_vendor, but guesses blas in some cases
        # where determine_vendor returns :unknown
        ret = BLAS.vendor()
        if Base.Sys.isapple() && (ret == :unknown)
            ret = :osxblas
        end
        ret
    end

    """
        Compat.set_num_threads(n)

    Set the number of threads the BLAS library should use.

    Also accepts `nothing`, in which case julia tries to guess the default number of threads.
    Passing `nothing` is discouraged and mainly exists because,
    on exotic variants of BLAS, `nothing` may be returned by `get_num_threads()`.
    Thus the following pattern may fail to set the number of threads, but will not error:
    ```julia
    old = get_num_threads()
    set_num_threads(1)
    @threads for i in 1:10
        # single-threaded BLAS calls
    end
    set_num_threads(old)
    ```
    """
    set_num_threads(n)::Nothing = _set_num_threads(n)

    function _set_num_threads(n::Integer; _blas = guess_vendor())
        if _blas === :openblas || _blas == :openblas64
            return ccall((BLAS.@blasfunc(openblas_set_num_threads), BLAS.libblas), Cvoid, (Cint,), n)
        elseif _blas === :mkl
           # MKL may let us set the number of threads in several ways
            return ccall((:MKL_Set_Num_Threads, BLAS.libblas), Cvoid, (Cint,), n)
            elseif _blas === :osxblas
            # OSX BLAS looks at an environment variable
            ENV["VECLIB_MAXIMUM_THREADS"] = n
        else
            @assert _blas === :unknown
            @warn "Failed to set number of BLAS threads." maxlog=1
        end
        return nothing
    end
    _tryparse_env_int(key) = tryparse(Int, get(ENV, key, ""))

    function _set_num_threads(::Nothing; _blas = guess_vendor())
        n = something(
            _tryparse_env_int("OPENBLAS_NUM_THREADS"),
            _tryparse_env_int("OMP_NUM_THREADS"),
            max(1, Base.Sys.CPU_THREADS ÷ 2),
        )
        _set_num_threads(n; _blas = _blas)
    end

    """
        Compat.get_num_threads()

    Get the number of threads the BLAS library is using.

    On exotic variants of `BLAS` this function can fail,
    which is indicated by returning `nothing`.

    In Julia 1.6 this is `LinearAlgebra.BLAS.get_num_threads()`
    """
    get_num_threads(;_blas=guess_vendor())::Union{Int, Nothing} = _get_num_threads()

    function _get_num_threads(; _blas = guess_vendor())::Union{Int, Nothing}
        if _blas === :openblas || _blas === :openblas64
            return Int(ccall((BLAS.@blasfunc(openblas_get_num_threads), BLAS.libblas), Cint, ()))
        elseif _blas === :mkl
            return Int(ccall((:mkl_get_max_threads, BLAS.libblas), Cint, ()))
        elseif _blas === :osxblas
            key = "VECLIB_MAXIMUM_THREADS"
            nt = _tryparse_env_int(key)
            if nt === nothing
                @warn "Failed to read environment variable $key" maxlog=1
            else
                return nt
            end
        else
            @assert _blas === :unknown
        end
        @warn "Could not get number of BLAS threads. Returning `nothing` instead." maxlog=1
        return nothing
    end

else
    # Ensure that these can still be accessed as Compat.get_num_threads() etc:
    import LinearAlgebra.BLAS: set_num_threads, get_num_threads
end

# https://github.com/JuliaLang/julia/pull/30915
if VERSION < v"1.2.0-DEV.257" # e7e726b3df1991e1306ef0c566d363c0a83b2dea
    Base.:(!=)(x) = Base.Fix2(!=, x)
    Base.:(>=)(x) = Base.Fix2(>=, x)
    Base.:(<=)(x) = Base.Fix2(<=, x)
    Base.:(>)(x) = Base.Fix2(>, x)
    Base.:(<)(x) = Base.Fix2(<, x)
end

# https://github.com/JuliaLang/julia/pull/35132
if VERSION < v"1.5.0-DEV.639" # cc6e121386758dff6ba7911770e48dfd59520199
    export contains
    contains(haystack::AbstractString, needle) = occursin(needle, haystack)
    contains(needle) = Base.Fix2(contains, needle)
end

# https://github.com/JuliaLang/julia/pull/35052
if VERSION < v"1.5.0-DEV.438" # 0a43c0f1d21ce9c647c49111d93927369cd20f85
    Base.endswith(s) = Base.Fix2(endswith, s)
    Base.startswith(s) = Base.Fix2(startswith, s)
end

# https://github.com/JuliaLang/julia/pull/37517
if VERSION < v"1.6.0-DEV.1037"
    export ComposedFunction
    # https://github.com/JuliaLang/julia/pull/35980
    if VERSION < v"1.6.0-DEV.85"
        const ComposedFunction = let h = identity ∘ convert
            Base.typename(typeof(h)).wrapper
        end
        @eval ComposedFunction{F,G}(f, g) where {F,G} =
            $(Expr(:new, :(ComposedFunction{F,G}), :f, :g))
        ComposedFunction(f, g) = ComposedFunction{Core.Typeof(f),Core.Typeof(g)}(f, g)
    else
        using Base: ComposedFunction
    end
    function Base.getproperty(c::ComposedFunction, p::Symbol)
        if p === :f
            return getfield(c, :f)
        elseif p === :g
            return getfield(c, :g)
        elseif p === :outer
            return getfield(c, :f)
        elseif p === :inner
            return getfield(c, :g)
        end
        error("type ComposedFunction has no property ", p)
    end
    Base.propertynames(c::ComposedFunction) = (:f, :g, :outer, :inner)
else
    using Base: ComposedFunction
end

# https://github.com/JuliaLang/julia/pull/37244
if VERSION < v"1.6.0-DEV.873" # 18198b1bf85125de6cec266eac404d31ccc2e65c
    export addenv
    function addenv(cmd::Cmd, env::Dict)
        new_env = Dict{String,String}()
        if cmd.env !== nothing
            for (k, v) in split.(cmd.env, "=")
                new_env[string(k)::String] = string(v)::String
            end
        end
        for (k, v) in env
            new_env[string(k)::String] = string(v)::String
        end
        return setenv(cmd, new_env)
    end

    function addenv(cmd::Cmd, pairs::Pair{<:AbstractString}...)
        return addenv(cmd, Dict(k => v for (k, v) in pairs))
    end

    function addenv(cmd::Cmd, env::Vector{<:AbstractString})
        return addenv(cmd, Dict(k => v for (k, v) in split.(env, "=")))
    end
end


# https://github.com/JuliaLang/julia/pull/37559
if VERSION < v"1.6.0-DEV.1083"
    """
        reinterpret(reshape, T, A::AbstractArray{S}) -> B

    Change the type-interpretation of `A` while consuming or adding a "channel dimension."

    If `sizeof(T) = n*sizeof(S)` for `n>1`, `A`'s first dimension must be
    of size `n` and `B` lacks `A`'s first dimension. Conversely, if `sizeof(S) = n*sizeof(T)` for `n>1`,
    `B` gets a new first dimension of size `n`. The dimensionality is unchanged if `sizeof(T) == sizeof(S)`.

    # Examples

    ```
    julia> A = [1 2; 3 4]
    2×2 Matrix{$Int}:
     1  2
     3  4

    julia> reinterpret(reshape, Complex{Int}, A)    # the result is a vector
    2-element reinterpret(reshape, Complex{$Int}, ::Matrix{$Int}):
     1 + 3im
     2 + 4im

    julia> a = [(1,2,3), (4,5,6)]
    2-element Vector{Tuple{$Int, $Int, $Int}}:
     (1, 2, 3)
     (4, 5, 6)

    julia> reinterpret(reshape, Int, a)             # the result is a matrix
    3×2 reinterpret(reshape, $Int, ::Vector{Tuple{$Int, $Int, $Int}}):
     1  4
     2  5
     3  6
    ```
    """
    function Base.reinterpret(::typeof(reshape), ::Type{T}, a::A) where {T,S,A<:AbstractArray{S}}
        isbitstype(T) || throwbits(S, T, T)
        isbitstype(S) || throwbits(S, T, S)
        if sizeof(S) == sizeof(T)
            N = ndims(a)
        elseif sizeof(S) > sizeof(T)
            rem(sizeof(S), sizeof(T)) == 0 || throwintmult(S, T)
            N = ndims(a) + 1
        else
            rem(sizeof(T), sizeof(S)) == 0 || throwintmult(S, T)
            N = ndims(a) - 1
            N > -1 || throwsize0(S, T, "larger")
            axes(a, 1) == Base.OneTo(sizeof(T) ÷ sizeof(S)) || throwsize1(a, T)
        end
        paxs = axes(a)
        new_axes = if sizeof(S) > sizeof(T)
            (Base.OneTo(div(sizeof(S), sizeof(T))), paxs...)
        elseif sizeof(S) < sizeof(T)
            Base.tail(paxs)
        else
            paxs
        end
        reshape(reinterpret(T, vec(a)), new_axes)
    end

    @noinline function throwintmult(S::Type, T::Type)
        throw(ArgumentError("`reinterpret(reshape, T, a)` requires that one of `sizeof(T)` (got $(sizeof(T))) and `sizeof(eltype(a))` (got $(sizeof(S))) be an integer multiple of the other"))
    end
    @noinline function throwsize1(a::AbstractArray, T::Type)
        throw(ArgumentError("`reinterpret(reshape, $T, a)` where `eltype(a)` is $(eltype(a)) requires that `axes(a, 1)` (got $(axes(a, 1))) be equal to 1:$(sizeof(T) ÷ sizeof(eltype(a))) (from the ratio of element sizes)"))
    end
    @noinline function throwbits(S::Type, T::Type, U::Type)
        throw(ArgumentError("cannot reinterpret `$(S)` as `$(T)`, type `$(U)` is not a bits type"))
    end
    @noinline function throwsize0(S::Type, T::Type, msg)
        throw(ArgumentError("cannot reinterpret a zero-dimensional `$(S)` array to `$(T)` which is of a $msg size"))
    end
end

if VERSION < v"1.3.0-alpha.115"
    # https://github.com/JuliaLang/julia/pull/29634
    # Note this is much less performant than real 5-arg mul!, but is provided so old versions of julia don't error at least

    function _mul!(C, A, B, alpha, beta)
        Y = similar(C)
        LinearAlgebra.mul!(Y, A, B)
        C .= Y .* alpha .+ C .* beta
        return C
    end

    # all combination of Number and AbstractArray for A and B except both being Number
    function LinearAlgebra.mul!(C::AbstractArray, A::Number, B::AbstractArray, alpha::Number, beta::Number)
        return _mul!(C, A, B, alpha, beta)
    end
    function LinearAlgebra.mul!(C::AbstractArray, A::AbstractArray, B::Number, alpha::Number, beta::Number)
        return _mul!(C, A, B, alpha, beta)
    end
    function LinearAlgebra.mul!(C::AbstractArray, A::AbstractArray, B::AbstractArray, alpha::Number, beta::Number)
        return _mul!(C, A, B, alpha, beta)
    end
end

# https://github.com/JuliaLang/julia/pull/35243
if VERSION < v"1.6.0-DEV.15"
    _replace_filename(@nospecialize(x), filename, line_offset=0) = x
    function _replace_filename(x::LineNumberNode, filename, line_offset=0)
        return LineNumberNode(x.line + line_offset, filename)
    end
    function _replace_filename(ex::Expr, filename, line_offset=0)
        return Expr(
            ex.head,
            Any[_replace_filename(i, filename, line_offset) for i in ex.args]...,
        )
    end

    function parseatom(text::AbstractString, pos::Integer; filename="none")
        ex, i = Meta.parse(text, pos, greedy=false)
        return _replace_filename(ex, Symbol(filename)), i
    end

    function _skip_newlines(text, line, i)
        while i <= lastindex(text) && isspace(text[i])
            line += text[i] == '\n'
            i = nextind(text, i)
        end
        return line, i
    end

    function parseall(text::AbstractString; filename="none")
        filename = Symbol(filename)
        ex = Expr(:toplevel)
        line, prev_i = _skip_newlines(text, 1, firstindex(text))
        ex_n, i = Meta.parse(text, prev_i)
        while ex_n !== nothing
            push!(ex.args, LineNumberNode(line, filename))
            push!(ex.args, _replace_filename(ex_n, filename, line-1))
            line += count(==('\n'), SubString(text, prev_i:prevind(text, i)))
            line, prev_i = _skip_newlines(text, line, i)
            ex_n, i = Meta.parse(text, prev_i)
        end
        return ex
    end
else
    using .Meta: parseatom, parseall
end

# https://github.com/JuliaLang/julia/pull/37391
if VERSION < v"1.6.0-DEV.820"
    Dates.canonicalize(p::Period) = Dates.canonicalize(CompoundPeriod(p))
end

# https://github.com/JuliaLang/julia/pull/35816
if VERSION < v"1.6.0-DEV.292" # 6cd329c371c1db3d9876bc337e82e274e50420e8
    export sincospi
    sincospi(x) = (sinpi(x), cospi(x))
end

# https://github.com/JuliaLang/julia/pull/38449
if VERSION < v"1.6.0-DEV.1591" # 96d59f957e4c0413e2876592072c0f08a7482cf2
    export cispi
    cispi(theta::Real) = Complex(reverse(sincospi(theta))...)
    function cispi(z::Complex)
        sipi, copi = sincospi(z)
        return complex(real(copi) - imag(sipi), imag(copi) + real(sipi))
    end
end

# https://github.com/JuliaLang/julia/pull/37065
# https://github.com/JuliaLang/julia/pull/38250
if VERSION < v"1.6.0-DEV.1536" # 5be3e27e029835cb56dd6934d302680c26f6e21b
    using LinearAlgebra: mul!, AdjointAbsVec, TransposeAbsVec, AdjOrTransAbsVec

    """
        muladd(A, y, z)

    Combined multiply-add, `A*y .+ z`, for matrix-matrix or matrix-vector multiplication.
    The result is always the same size as `A*y`, but `z` may be smaller, or a scalar.

    # Examples
    ```jldoctest
    julia> A=[1.0 2.0; 3.0 4.0]; B=[1.0 1.0; 1.0 1.0]; z=[0, 100];

    julia> muladd(A, B, z)
    2×2 Matrix{Float64}:
       3.0    3.0
     107.0  107.0
    ```
    """
    function Base.muladd(A::AbstractMatrix, y::AbstractVecOrMat, z::Union{Number, AbstractArray})
        Ay = _safe_mul(A, y)
        for d in 1:ndims(Ay)
            # Same error as Ay .+= z would give, to match StridedMatrix method:
            size(z,d) > size(Ay,d) && throw(DimensionMismatch("array could not be broadcast to match destination"))
        end
        for d in ndims(Ay)+1:ndims(z)
            # Similar error to what Ay + z would give, to match (Any,Any,Any) method:
            size(z,d) > 1 && throw(DimensionMismatch(string("dimensions must match: z has dims ",
                axes(z), ", must have singleton at dim ", d)))
        end
        Ay .+ z
    end

    _safe_mul(A, y) = A * y
    if VERSION < v"1.5"
        _safe_mul(vt::AdjOrTransAbsVec, y::AbstractVector) = _dot_nonrecursive(vt, y)
    end

    function Base.muladd(u::AbstractVector, v::AdjOrTransAbsVec, z::Union{Number, AbstractArray})
        if size(z,1) > length(u) || size(z,2) > length(v)
            # Same error as (u*v) .+= z:
            throw(DimensionMismatch("array could not be broadcast to match destination"))
        end
        for d in 3:ndims(z)
            # Similar error to (u*v) + z:
            size(z,d) > 1 && throw(DimensionMismatch(string("dimensions must match: z has dims ",
                axes(z), ", must have singleton at dim ", d)))
        end
        (u .* v) .+ z
    end

    Base.muladd(x::AdjointAbsVec, A::AbstractMatrix, z::Union{Number, AbstractVecOrMat}) =
        muladd(A', x', z')'
    Base.muladd(x::TransposeAbsVec, A::AbstractMatrix, z::Union{Number, AbstractVecOrMat}) =
        transpose(muladd(transpose(A), transpose(x), transpose(z)))

    StridedMaybeAdjOrTransMat{T} = Union{StridedMatrix{T}, Adjoint{T, <:StridedMatrix}, Transpose{T, <:StridedMatrix}}

    function Base.muladd(A::StridedMaybeAdjOrTransMat{<:Number}, y::AbstractVector{<:Number}, z::Union{Number, AbstractVector})
        T = promote_type(eltype(A), eltype(y), eltype(z))
        C = similar(A, T, axes(A,1))
        C .= z
        mul!(C, A, y, true, true)
    end

    function Base.muladd(A::StridedMaybeAdjOrTransMat{<:Number}, B::StridedMaybeAdjOrTransMat{<:Number}, z::Union{Number, AbstractVecOrMat})
        T = promote_type(eltype(A), eltype(B), eltype(z))
        C = similar(A, T, axes(A,1), axes(B,2))
        C .= z
        mul!(C, A, B, true, true)
    end

    Base.muladd(A::Diagonal, B::Diagonal, z::Diagonal) =
        Diagonal(A.diag .* B.diag .+ z.diag)
    Base.muladd(A::UniformScaling, B::UniformScaling, z::UniformScaling) =
        UniformScaling(A.λ * B.λ + z.λ)
    Base.muladd(A::Union{Diagonal, UniformScaling}, B::Union{Diagonal, UniformScaling}, z::Union{Diagonal, UniformScaling}) =
        Diagonal(_diag_or_value(A) .* _diag_or_value(B) .+ _diag_or_value(z))

    _diag_or_value(A::Diagonal) = A.diag
    _diag_or_value(A::UniformScaling) = A.λ

    function _dot_nonrecursive(u, v) # in LinearAlgebra on Julia 1.5
        lu = length(u)
        if lu != length(v)
            throw(DimensionMismatch("first array has length $(lu) which does not match the length of the second, $(length(v))."))
        end
        if lu == 0
            zero(eltype(u)) * zero(eltype(v))
        else
            sum(uu*vv for (uu, vv) in zip(u, v))
        end
    end
end

# https://github.com/JuliaLang/julia/pull/29790
if VERSION < v"1.2.0-DEV.246"
    using Base.PCRE

    function Base.startswith(s::AbstractString, r::Regex)
        Base.compile(r)
        return PCRE.exec(
            r.regex, String(s), 0, r.match_options | PCRE.ANCHORED, r.match_data
        )
    end

    function Base.startswith(s::SubString, r::Regex)
        Base.compile(r)
        return PCRE.exec(r.regex, s, 0, r.match_options | PCRE.ANCHORED, r.match_data)
    end

    function Base.endswith(s::AbstractString, r::Regex)
        Base.compile(r)
        return PCRE.exec(
            r.regex, String(s), 0, r.match_options | PCRE.ENDANCHORED, r.match_data
        )
    end

    function Base.endswith(s::SubString, r::Regex)
        Base.compile(r)
        return PCRE.exec(r.regex, s, 0, r.match_options | PCRE.ENDANCHORED, r.match_data)
    end
end

if VERSION < v"1.7.0-DEV.119"
    # Part of:
    # https://github.com/JuliaLang/julia/pull/35316
    # https://github.com/JuliaLang/julia/pull/41076
    isunordered(x) = false
    isunordered(x::AbstractFloat) = isnan(x)
    isunordered(x::Missing) = true

    isgreater(x, y) = isunordered(x) || isunordered(y) ? isless(x, y) : isless(y, x)

    Base.findmax(f, domain) = mapfoldl( ((k, v),) -> (f(v), k), _rf_findmax, pairs(domain) )
    _rf_findmax((fm, im), (fx, ix)) = isless(fm, fx) ? (fx, ix) : (fm, im)

    Base.findmin(f, domain) = mapfoldl( ((k, v),) -> (f(v), k), _rf_findmin, pairs(domain) )
    _rf_findmin((fm, im), (fx, ix)) = isgreater(fm, fx) ? (fx, ix) : (fm, im)

    Base.argmax(f, domain) = mapfoldl(x -> (f(x), x), _rf_findmax, domain)[2]
    Base.argmin(f, domain) = mapfoldl(x -> (f(x), x), _rf_findmin, domain)[2]
end

# Part of: https://github.com/JuliaLang/julia/pull/36018
if VERSION < v"1.6.0-DEV.749"
    import UUIDs: UUID
    UUID(u::UUID) = u
end

# https://github.com/JuliaLang/julia/pull/36199
if VERSION < v"1.6.0-DEV.196"
    using UUIDs: UUID
    Base.parse(::Type{UUID}, s::AbstractString) = UUID(s)
end

# https://github.com/JuliaLang/julia/pull/37454
if VERSION < v"1.6.0-DEV.877"
    Base.NamedTuple(itr) = (; itr...)
end

# https://github.com/JuliaLang/julia/pull/40729
if VERSION < v"1.7.0-DEV.1088"
    macro something(args...)
        expr = :(nothing)
        for arg in reverse(args)
            expr = :((val = $arg) !== nothing ? val : $expr)
        end
        return esc(:(something(let val; $expr; end)))
    end

    macro coalesce(args...)
        expr = :(missing)
        for arg in reverse(args)
            expr = :((val = $arg) !== missing ? val : $expr)
        end
        return esc(:(let val; $expr; end))
    end

    export @something, @coalesce
end

import Base: get, Dims, Callable

# https://github.com/JuliaLang/julia/pull/41007
if VERSION < v"1.7.0-DEV.1220"
    get(f::Callable, A::AbstractArray, i::Integer) = checkbounds(Bool, A, i) ? A[i] : f()
    get(f::Callable, A::AbstractArray, I::Tuple{}) = checkbounds(Bool, A) ? A[] : f()
    get(f::Callable, A::AbstractArray, I::Dims) = checkbounds(Bool, A, I...) ? A[I...] : f()

    get(t::Tuple, i::Integer, default) = i in 1:length(t) ? getindex(t, i) : default
    get(f::Callable, t::Tuple, i::Integer) = i in 1:length(t) ? getindex(t, i) : f()
end

# https://github.com/JuliaLang/julia/pull/41032
if VERSION < v"1.7.0-DEV.1230"
    get(x::Number, i::Integer, default) = isone(i) ? x : default
    get(x::Number, ind::Tuple, default) = all(isone, ind) ? x : default
    get(f::Callable, x::Number, i::Integer) = isone(i) ? x : f()
    get(f::Callable, x::Number, ind::Tuple) = all(isone, ind) ? x : f()
end

# https://github.com/JuliaLang/julia/pull/34595
if VERSION < v"1.5.0-DEV.263"
    function Base.include(mapexpr::Function, m::Module, path::AbstractString)
        code = read(path, String)
        return include_string(mapexpr, m, code, abspath(path))
    end
    function Base.include_string(mapexpr::Function, m::Module, code::AbstractString,
                                 filename::AbstractString="string")
        ex = parseall(code; filename=filename)
        @assert Meta.isexpr(ex, :toplevel)
        map!(x -> x isa LineNumberNode ? x : mapexpr(x), ex.args, ex.args)
        return Core.eval(m, ex)
    end
end

# https://github.com/JuliaLang/julia/pull/29901
if VERSION < v"1.7.0-DEV.1106"
    struct ExceptionStack <: AbstractArray{Any,1}
        stack
    end

    if VERSION >= v"1.1"
        function current_exceptions(task=current_task(); backtrace=true)
            old_stack = Base.catch_stack(task, include_bt=backtrace)
            # If include_bt=true, Base.catch_stack yields a Vector of two-tuples,
            # where the first element of each tuple is an exception and the second
            # element is the corresponding backtrace. If instead include_bt=false,
            # Base.catch_stack yields a Vector of exceptions.
            #
            # Independent of its backtrace keyword argument, Base.current_exceptions
            # yields an ExceptionStack that wraps a Vector of two-element
            # NamedTuples, where the first element of each named tuple is an exception
            # and the second element is either a correpsonding backtrace or `nothing`.
            #
            # The following constructs the ExceptionStack-wrapped Vector appropriately.
            new_stack = backtrace ?
                Any[(exception=exc_and_bt[1], backtrace=exc_and_bt[2]) for exc_and_bt in old_stack] :
                Any[(exception=exc_only,      backtrace=nothing) for exc_only in old_stack]
            return ExceptionStack(new_stack)
        end
    else
        # There's no exception stack in 1.0, but we can fall back to returning
        # the (single) current exception and backtrace instead.
        @eval function current_exceptions(task=current_task(); backtrace=true)
            bt = catch_backtrace()
            stack = if isempty(bt)
                Any[]
            else
                # Note that `exc = Expr(:the_exception)` is the lowering for `catch exc`,
                # and please see the comment in the implementation for >v1.1 regarding
                # the `backtrace ? bt : nothing`.
                Any[(exception=$(Expr(:the_exception)), backtrace = backtrace ? bt : nothing)]
            end
            return ExceptionStack(stack)
        end
        @eval function the_stack()
           $(Expr(:the_exception)), catch_backtrace()
        end
    end

    Base.size(s::ExceptionStack) = size(s.stack)
    Base.getindex(s::ExceptionStack, i::Int) = s.stack[i]

    function show_exception_stack(io::IO, stack)
        # Display exception stack with the top of the stack first.  This ordering
        # means that the user doesn't have to scroll up in the REPL to discover the
        # root cause.
        nexc = length(stack)
        for i = nexc:-1:1
            if nexc != i
                printstyled(io, "\ncaused by: ", color=Base.error_color())
            end
            exc, bt = stack[i]
            showerror(io, exc, bt, backtrace = bt!==nothing)
            i == 1 || println(io)
        end
    end

    function Base.display_error(io::IO, stack::ExceptionStack)
        printstyled(io, "ERROR: "; bold=true, color=Base.error_color())
        # Julia >=1.2 provides Base.scrub_repl_backtrace; we use it
        # where possible and otherwise leave backtraces unscrubbed.
        backtrace_scrubber = VERSION >= v"1.2" ? Base.scrub_repl_backtrace : identity
        bt = Any[ (x[1], backtrace_scrubber(x[2])) for x in stack ]
        show_exception_stack(IOContext(io, :limit => true), bt)
        println(io)
    end

    function Base.show(io::IO, ::MIME"text/plain", stack::ExceptionStack)
        nexc = length(stack)
        printstyled(io, nexc, "-element ExceptionStack", nexc == 0 ? "" : ":\n")
        show_exception_stack(io, stack)
    end
    Base.show(io::IO, stack::ExceptionStack) = show(io, MIME("text/plain"), stack)

    export current_exceptions
end

# https://github.com/JuliaLang/julia/pull/39794
if VERSION < v"1.7.0-DEV.793"
    export Returns

    struct Returns{V} <: Function
        value::V
        Returns{V}(value) where {V} = new{V}(value)
        Returns(value) = new{Core.Typeof(value)}(value)
    end

    (obj::Returns)(args...; kw...) = obj.value
    function Base.show(io::IO, obj::Returns)
        show(io, typeof(obj))
        print(io, "(")
        show(io, obj.value)
        print(io, ")")
    end
end

# https://github.com/JuliaLang/julia/pull/39037
if VERSION < v"1.7.0-DEV.204"
    # Borrowed from julia base
    export ismutabletype
    function ismutabletype(@nospecialize(t::Type))
        t = Base.unwrap_unionall(t)
        # TODO: what to do for `Union`?
        return isa(t, DataType) && t.mutable
    end
end

# https://github.com/JuliaLang/julia/pull/42125
if !isdefined(Base, Symbol("@constprop"))
    if isdefined(Base, Symbol("@aggressive_constprop"))
        macro constprop(setting, ex)
            if isa(setting, QuoteNode)
                setting = setting.value
            end
            setting === :aggressive && return esc(:(Base.@aggressive_constprop $ex))
            setting === :none && return esc(ex)
            throw(ArgumentError("@constprop $setting not supported"))
        end
    else
        macro constprop(setting, ex)
            if isa(setting, QuoteNode)
                setting = setting.value
            end
            setting === :aggressive || setting === :none || throw(ArgumentError("@constprop $setting not supported"))
            return esc(ex)
        end
    end
else
    using Base: @constprop
end

# https://github.com/JuliaLang/julia/pull/40803
if VERSION < v"1.8.0-DEV.300"
    function Base.convert(::Type{T}, x::CompoundPeriod) where T<:Period
        return isconcretetype(T) ? sum(T, x.periods) : throw(MethodError(convert, (T, x)))
    end
end

# https://github.com/JuliaLang/julia/pull/39245
if VERSION < v"1.8.0-DEV.487"  
    export eachsplit
    
    """
        eachsplit(str::AbstractString, dlm; limit::Integer=0)
        eachsplit(str::AbstractString; limit::Integer=0)

    Split `str` on occurrences of the delimiter(s) `dlm` and return an iterator over the
    substrings.  `dlm` can be any of the formats allowed by [`findnext`](@ref)'s first argument
    (i.e. as a string, regular expression or a function), or as a single character or collection
    of characters.
    
    If `dlm` is omitted, it defaults to [`isspace`](@ref).
    
    The iterator will return a maximum of `limit` results if the keyword argument is supplied.
    The default of `limit=0` implies no maximum.
    
    See also [`split`](@ref).
    
    # Examples
    ```julia
    julia> a = "Ma.rch"
    "Ma.rch"
    julia> collect(eachsplit(a, "."))
    2-element Vector{SubString}:
    "Ma"
    "rch"
    ```
    """
    function eachsplit end
    
    struct SplitIterator{S<:AbstractString,F}
        str::S
        splitter::F
        limit::Int
        keepempty::Bool
    end

    Base.eltype(::Type{<:SplitIterator}) = SubString
    Base.IteratorSize(::Type{<:SplitIterator}) = Base.SizeUnknown()
    
    function Base.iterate(iter::SplitIterator, (i, k, n)=(firstindex(iter.str), firstindex(iter.str), 0))
        i - 1 > ncodeunits(iter.str)::Int && return nothing
        r = findnext(iter.splitter, iter.str, k)::Union{Nothing,Int,UnitRange{Int}}
        while r !== nothing && n != iter.limit - 1 && first(r) <= ncodeunits(iter.str)
            r = r::Union{Int,UnitRange{Int}} #commit dcc2182db228935fe97d03a44ae3b6889e40c542
            #follow #39245, improve inferrability of iterate(::SplitIterator)            
            #Somehow type constraints from the complex `while` condition don't
            #propagate to the `while` body.
            j, k = first(r), nextind(iter.str, last(r))::Int
            k_ = k <= j ? nextind(iter.str, j) : k
            if i < k
                substr = @inbounds SubString(iter.str, i, prevind(iter.str, j)::Int)
                (iter.keepempty || i < j) && return (substr, (k, k_, n + 1))
                i = k
            end
            k = k_
            r = findnext(iter.splitter, iter.str, k)::Union{Nothing,Int,UnitRange{Int}}
        end
        iter.keepempty || i <= ncodeunits(iter.str) || return nothing
        @inbounds SubString(iter.str, i), (ncodeunits(iter.str) + 2, k, n + 1)
    end

    eachsplit(str::T, splitter; limit::Integer=0, keepempty::Bool=true) where {T<:AbstractString} =
        SplitIterator(str, splitter, limit, keepempty)

    eachsplit(str::T, splitter::Union{Tuple{Vararg{AbstractChar}},AbstractVector{<:AbstractChar},Set{<:AbstractChar}};
            limit::Integer=0, keepempty=true) where {T<:AbstractString} =
        eachsplit(str, in(splitter); limit=limit, keepempty=keepempty)

    eachsplit(str::T, splitter::AbstractChar; limit::Integer=0, keepempty=true) where {T<:AbstractString} =
        eachsplit(str, isequal(splitter); limit=limit, keepempty=keepempty)

    eachsplit(str::AbstractString; limit::Integer=0, keepempty=false) =
        eachsplit(str, isspace; limit=limit, keepempty=keepempty)
end

# https://github.com/JuliaLang/julia/pull/43354
if VERSION < v"1.8.0-DEV.1494" # 98e60ffb11ee431e462b092b48a31a1204bd263d
    export allequal
    allequal(itr) = isempty(itr) ? true : all(isequal(first(itr)), itr)
    allequal(c::Union{AbstractSet,AbstractDict}) = length(c) <= 1
    allequal(r::AbstractRange) = iszero(step(r)) || length(r) <= 1
end


include("iterators.jl")
include("deprecated.jl")

end # module Compat
