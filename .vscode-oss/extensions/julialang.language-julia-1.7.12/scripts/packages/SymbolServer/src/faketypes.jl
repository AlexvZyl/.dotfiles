########## Fake type-system


# Used to label all objects
struct VarRef
    parent::Union{VarRef,Nothing}
    name::Symbol
end
VarRef(m::Module) = VarRef((parentmodule(m) == Main || parentmodule(m) == m) ? nothing : VarRef(parentmodule(m)), nameof(m))

# These mirror Julia types (w/o the Fake prefix)
struct FakeTypeName
    name::VarRef
    parameters::Vector{Any}
end

function FakeTypeName(@nospecialize(x); justname=false)
    @static if !(Vararg isa Type)
        x isa typeof(Vararg) && return FakeTypeofVararg(x)
    end
    if x isa DataType
        xname = x.name
        xnamename = xname.name # necessary but unclear why.
        if justname
            FakeTypeName(VarRef(VarRef(x.name.module), x.name.name), [])
        else
            # FakeTypeName(VarRef(VarRef(x.name.module), x.name.name), _parameter.(x.parameters))
            ft = FakeTypeName(VarRef(VarRef(x.name.module), x.name.name), [])
            for p in x.parameters
                push!(ft.parameters, _parameter(p))
            end
            ft
        end
    elseif x isa Union
        FakeUnion(x)
    elseif x isa UnionAll
        FakeUnionAll(x)
    elseif x isa TypeVar
        FakeTypeVar(x)
    elseif x isa Core.TypeofBottom
        FakeTypeofBottom()
    else
        error((x, typeof(x)))
    end
end

struct FakeTypeofBottom end
struct FakeUnion
    a
    b
end
FakeUnion(u::Union) = FakeUnion(FakeTypeName(u.a, justname=true), FakeTypeName(u.b, justname=true))
struct FakeTypeVar
    name::Symbol
    lb
    ub
end
FakeTypeVar(tv::TypeVar) = FakeTypeVar(tv.name, FakeTypeName(tv.lb, justname=true), FakeTypeName(tv.ub, justname=true))
struct FakeUnionAll
    var::FakeTypeVar
    body::Any
end
FakeUnionAll(ua::UnionAll) = FakeUnionAll(FakeTypeVar(ua.var), FakeTypeName(ua.body, justname=true))

function _parameter(@nospecialize(p))
    if p isa Union{Int,Symbol,Bool,Char}
        p
    elseif !(p isa Type) && isbitstype(typeof(p))
        0
    elseif p isa Tuple
        _parameter.(p)
    else
        FakeTypeName(p, justname=true)
    end
end

Base.print(io::IO, vr::VarRef) = vr.parent === nothing ? print(io, vr.name) : print(io, vr.parent, ".", vr.name)
function Base.print(io::IO, tn::FakeTypeName)
    print(io, tn.name)
    if !isempty(tn.parameters)
        print(io, "{")
        for i = 1:length(tn.parameters)
            print(io, tn.parameters[i])
            i != length(tn.parameters) && print(io, ",")
        end
        print(io, "}")
    end
end
Base.print(io::IO, x::FakeUnionAll) = print(io, x.body, " where ", x.var)
function Base.print(io::IO, x::FakeUnion; inunion=false)
    !inunion && print(io,  "Union{")
    print(io, x.a, ",")
    if x.b isa FakeUnion
        print(io, x.b, inunion=true)
    else
        print(io, x.b, "}")
    end
end
function Base.print(io::IO, x::FakeTypeVar)
    if isfakebottom(x.lb)
        if isfakeany(x.ub)
            print(io, x.name)
        else
            print(io, x.name, "<:", x.ub)
        end
    elseif isfakeany(x.ub)
        print(io, x.lb, "<:", x.name)
    else
        print(io, x.lb, "<:", x.name, "<:", x.ub)
    end
end

isfakeany(t) = false
isfakeany(t::FakeTypeName) = isfakeany(t.name)
isfakeany(vr::VarRef) = vr.name === :Any && vr.parent isa VarRef && vr.parent.name === :Core && vr.parent.parent === nothing

isfakebottom(t) = false
isfakebottom(t::FakeTypeofBottom) = true

Base.:(==)(a::FakeTypeName, b::FakeTypeName) = a.name == b.name && a.parameters == b.parameters
Base.:(==)(a::VarRef, b::VarRef) = a.parent == b.parent && a.name == b.name
Base.:(==)(a::FakeTypeVar, b::FakeTypeVar) = a.lb == b.lb && a.name == b.name && a.ub == b.ub
Base.:(==)(a::FakeUnionAll, b::FakeUnionAll) = a.var == b.var && a.body == b.body
Base.:(==)(a::FakeUnion, b::FakeUnion) = a.a == b.a && a.b == b.b
Base.:(==)(a::FakeTypeofBottom, b::FakeTypeofBottom) = true

@static if !(Vararg isa Type)
    struct FakeTypeofVararg
        T
        N
        FakeTypeofVararg() = new()
        FakeTypeofVararg(T) = (new(T))
        FakeTypeofVararg(T, N) = new(T, N)
    end
    function FakeTypeofVararg(va::typeof(Vararg))
        if isdefined(va, :N)
            vaN = va.N isa TypeVar ? FakeTypeVar(va.N) : va.N
            FakeTypeofVararg(FakeTypeName(va.T; justname=true), vaN) # This should be FakeTypeName(va.N) but seems to crash inference.
        elseif isdefined(va, :T)
            FakeTypeofVararg(FakeTypeName(va.T; justname=true))
        else
            FakeTypeofVararg()
        end
    end
    function Base.print(io::IO, va::FakeTypeofVararg)
        print(io, "Vararg")
        if isdefined(va, :T)
            print(io, "{", va.T)
            if isdefined(va, :N)
                print(io, ",", va.N)
            end
            print(io, "}")
        end
    end
    function Base.:(==)(a::FakeTypeofVararg, b::FakeTypeofVararg)
        if isdefined(a, :T)
            if isdefined(b, :T) && a.T == b.T
                if isdefined(a, :N)
                    isdefined(b, :N) && a.N == b.N
                else
                    !isdefined(b, :N)
                end
            else
                false
            end
        else
            !isdefined(b, :T)
        end
    end
end
