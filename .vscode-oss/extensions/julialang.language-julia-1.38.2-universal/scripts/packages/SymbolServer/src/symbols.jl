using LibGit2, InteractiveUtils

mutable struct Server
    storedir::String
    context::Pkg.Types.Context
    depot::Dict
end

abstract type SymStore end
struct ModuleStore <: SymStore
    name::VarRef
    vals::Dict{Symbol,Any}
    doc::String
    exported::Bool
    exportednames::Vector{Symbol}
    used_modules::Vector{Symbol}
end

ModuleStore(m) = ModuleStore(VarRef(m), Dict{Symbol,Any}(), _doc(Base.Docs.Binding(m, nameof(m))), true, unsorted_names(m), Symbol[])
Base.getindex(m::ModuleStore, k) = m.vals[k]
Base.setindex!(m::ModuleStore, v, k) = (m.vals[k] = v)
Base.haskey(m::ModuleStore, k) = haskey(m.vals, k)

const EnvStore = Dict{Symbol,ModuleStore}

struct Package
    name::String
    val::ModuleStore
    uuid::Base.UUID
    sha::Union{Vector{UInt8},Nothing}
end
Package(name::String, val::ModuleStore, uuid::String, sha) = Package(name, val, Base.UUID(uuid), sha)

struct MethodStore
    name::Symbol
    mod::Symbol
    file::String
    line::Int32
    sig::Vector{Pair{Any,Any}}
    kws::Vector{Symbol}
    rt::Any
end

struct DataTypeStore <: SymStore
    name::FakeTypeName
    super::FakeTypeName
    parameters::Vector{Any}
    types::Vector{Any}
    fieldnames::Vector{Any}
    methods::Vector{MethodStore}
    doc::String
    exported::Bool
end

function DataTypeStore(@nospecialize(t), symbol, parent_mod, exported)
    ur_t = Base.unwrap_unionall(t)
    parameters = if isdefined(ur_t, :parameters)
        map(ur_t.parameters) do p
            _parameter(p)
        end
    else
        []
    end
    types = if isdefined(ur_t, :types)
        map(ur_t.types) do p
            FakeTypeName(p)
        end
    else
        []
    end
    DataTypeStore(FakeTypeName(ur_t), FakeTypeName(ur_t.super), parameters, types, isconcretetype(ur_t) && fieldcount(ur_t) > 0 ? collect(fieldnames(ur_t)) : Symbol[], MethodStore[], _doc(Base.Docs.Binding(parent_mod, symbol)), exported)
end

struct FunctionStore <: SymStore
    name::VarRef
    methods::Vector{MethodStore}
    doc::String
    extends::VarRef
    exported::Bool
end

function FunctionStore(@nospecialize(f), symbol, parent_mod, exported)
    if f isa Core.IntrinsicFunction
        FunctionStore(VarRef(VarRef(Core.Intrinsics), nameof(f)), MethodStore[], _doc(Base.Docs.Binding(parent_mod, symbol)), VarRef(VarRef(parentmodule(f)), nameof(f)), exported)
    else
        FunctionStore(VarRef(VarRef(parent_mod), nameof(f)), MethodStore[], _doc(Base.Docs.Binding(parent_mod, symbol)), VarRef(VarRef(parentmodule(f)), nameof(f)), exported)
    end
end

struct GenericStore <: SymStore
    name::VarRef
    typ::Any
    doc::String
    exported::Bool
end

# adapted from https://github.com/timholy/CodeTracking.jl/blob/afc73a957f5034cc7f02e084a91283c47882f92b/src/utils.jl#L87-L122

"""
    path = maybe_fix_path(path)

Return a normalized, absolute path for a source file `path`.
"""
function maybe_fix_path(file)
    if !isabspath(file)
        # This may be a Base or Core method
        newfile = Base.find_source_file(file)
        if isa(newfile, AbstractString)
            file = normpath(newfile)
        end
    end
    return maybe_fixup_stdlib_path(file)
end

safe_isfile(x) = try isfile(x); catch; false end
const BUILDBOT_STDLIB_PATH = dirname(abspath(joinpath(String((@which versioninfo()).file), "..", "..", "..")))
replace_buildbot_stdlibpath(str::String) = replace(str, BUILDBOT_STDLIB_PATH => Sys.STDLIB)
"""
    path = maybe_fixup_stdlib_path(path::String)

Return `path` corrected for julia issue [#26314](https://github.com/JuliaLang/julia/issues/26314) if applicable.
Otherwise, return the input `path` unchanged.

Due to the issue mentioned above, location info for methods defined one of Julia's standard libraries
are, for non source Julia builds, given as absolute paths on the worker that built the `julia` executable.
This function corrects such a path to instead refer to the local path on the users drive.
"""
function maybe_fixup_stdlib_path(path)
    if !safe_isfile(path)
        maybe_stdlib_path = replace_buildbot_stdlibpath(path)
        safe_isfile(maybe_stdlib_path) && return maybe_stdlib_path
    end
    return path
end

const _global_method_cache = IdDict{Any,Vector{Any}}()
function methodinfo(@nospecialize(f); types = Tuple, world = typemax(UInt))
    key = (f, types, world)
    cached = get(_global_method_cache, key, nothing)
    if cached === nothing
        cached = Base._methods(f, types, -1, world)
        _global_method_cache[key] = cached
    end
    return cached
end

function methodlist(@nospecialize(f))
    ms = methodinfo(f)
    Method[x[3]::Method for x in ms]
end

function sparam_syms(meth::Method)
    s = Symbol[]
    sig = meth.sig
    while sig isa UnionAll
        push!(s, Symbol(sig.var.name))
        sig = sig.body
    end
    return s
end

function cache_methods(@nospecialize(f), name, env, get_return_type)
    if isa(f, Core.Builtin)
        return MethodStore[]
    end
    types = Tuple
    world = typemax(UInt)
    ms = Tuple{Module,MethodStore}[]
    methods0 = try
        methodinfo(f; types = types, world = world)
    catch err
        return ms
    end
    ind_of_method_w_kws = Int[] # stores the index of methods with kws.
    i = 1
    for m in methods0
        # Get inferred method return type
        if get_return_type
            sparams = Core.svec(sparam_syms(m[3])...)
            rt = try 
                @static if isdefined(Core.Compiler, :NativeInterpreter)
                Core.Compiler.typeinf_type(Core.Compiler.NativeInterpreter(), m[3], m[3].sig, sparams)
            else
                Core.Compiler.typeinf_type(m[3], m[3].sig, sparams, Core.Compiler.Params(world))
            end
            catch e
                Any
            end
        else
            rt = Any
        end
        file = maybe_fix_path(String(m[3].file))
        MS = MethodStore(m[3].name, nameof(m[3].module), file, m[3].line, [], Symbol[], FakeTypeName(rt))
        # Get signature
        sig = Base.unwrap_unionall(m[1])
        argnames = getargnames(m[3])
        for i = 2:m[3].nargs
            push!(MS.sig, argnames[i] => FakeTypeName(sig.parameters[i]))
        end
        kws = getkws(m[3])
        if !isempty(kws)
            push!(ind_of_method_w_kws, i)
        end
        for kw in kws
            push!(MS.kws, kw)
        end
        push!(ms, (m[3].module, MS))
        i += 1
    end
    # Go back and add kws to methods defined in the same place as others with kws.
    for i in ind_of_method_w_kws
        for j = 1:length(ms) # only need to go up to `i`?
            if ms[j][2].file == ms[i][2].file && ms[j][2].line == ms[i][2].line && isempty(ms[j][2].kws)
                for kw in ms[i][2].kws
                    push!(ms[j][2].kws, kw)
                end
            end
        end
    end

    func_vr = VarRef(VarRef(parentmodule(f)), name)
    for i = 1:length(ms)
        mvr = VarRef(ms[i][1])
        modstore = _lookup(mvr, env)
        if modstore !== nothing
            if !haskey(modstore, name)
                modstore[name] = FunctionStore(VarRef(mvr, name), MethodStore[ms[i][2]], "", func_vr, false)
            elseif !(modstore[name] isa DataTypeStore || modstore[name] isa FunctionStore)
                modstore[name] = FunctionStore(VarRef(mvr, name), MethodStore[ms[i][2]], "", func_vr, false)
            else
                push!(modstore[name].methods, ms[i][2])
            end
        else
        end
    end
    return ms
end

getargnames(m::Method) = Base.method_argnames(m)
@static if length(first(methods(Base.kwarg_decl)).sig.parameters) == 2
    getkws = Base.kwarg_decl
else
    function getkws(m::Method)
        sig = Base.unwrap_unionall(m.sig)
        length(sig.parameters) == 0 && return []
        sig.parameters[1] isa Union && return []
        !isdefined(Base.unwrap_unionall(sig.parameters[1]), :name) && return []
        fname = Base.unwrap_unionall(sig.parameters[1]).name
        if isdefined(fname.mt, :kwsorter)
            Base.kwarg_decl(m, typeof(fname.mt.kwsorter))
        else
            []
        end
    end
end

function apply_to_everything(f, m = nothing, visited = Base.IdSet{Module}())
    if m isa Module
        push!(visited, m)
        for s in unsorted_names(m, all = true, imported = true)
            (!isdefined(m, s) || s == nameof(m)) && continue
            x = getfield(m, s)
            f(x)
            if x isa Module && !in(x, visited)
                apply_to_everything(f, x, visited)
            end
        end
    else
        for m in Base.loaded_modules_array()
            in(m, visited) || apply_to_everything(f, m, visited)
        end
    end
end



function oneverything(f, m = nothing, visited = Base.IdSet{Module}())
    if m isa Module
        push!(visited, m)
        state = nothing
        for s in unsorted_names(m, all = true, imported = true)
            !isdefined(m, s) && continue
            x = getfield(m, s)
            state = f(m, s, x, state)
            if x isa Module && !in(x, visited)
                oneverything(f, x, visited)
            end
        end
    else
        for m in Base.loaded_modules_array()
            in(m, visited) || oneverything(f, m, visited)
        end
    end
end

const _global_symbol_cache_by_mod = IdDict{Module,Base.IdSet{Symbol}}()
function build_namecache(m, s, @nospecialize(x), state::Union{Base.IdSet{Symbol},Nothing} = nothing)
    if state === nothing
        state = get(_global_symbol_cache_by_mod, m, nothing)
        if state === nothing
            state = _global_symbol_cache_by_mod[m] = Base.IdSet{Symbol}()
        end
    end
    push!(state, s)
end

function getnames(m::Module)
    cache = get(_global_symbol_cache_by_mod, m, nothing)
    if cache === nothing
        oneverything(build_namecache, m)
        cache = _global_symbol_cache_by_mod[m]
    end
    return cache
end

function allmodulenames()
    symbols = Base.IdSet{Symbol}()
    oneverything((m, s, x, state) -> (x isa Module && push!(symbols, s); return state))
    return symbols
end

function allthingswithmethods()
    symbols = Base.IdSet{Any}()
    oneverything(function (m, s, x, state)
        if !Base.isvarargtype(x) && !isempty(methodlist(x))
            push!(symbols, x)
        end
        return state
    end)
    return symbols
end

function allmethods()
    ms = Method[]
    oneverything(function (m, s, x, state)
        if !Base.isvarargtype(x) && !isempty(methodlist(x))
            append!(ms, methodlist(x))
        end
        return state
    end)
    return ms
end

usedby(outer, inner) = outer !== inner && isdefined(outer, nameof(inner)) && getproperty(outer, nameof(inner)) === inner && all(isdefined(outer, name) || !isdefined(inner, name) for name in unsorted_names(inner))
istoplevelmodule(m) = parentmodule(m) === m || parentmodule(m) === Main

function getmoduletree(m::Module, amn, visited = Base.IdSet{Module}())
    push!(visited, m)
    cache = ModuleStore(m)
    for s in unsorted_names(m, all = true, imported = true)
        !isdefined(m, s) && continue
        x = getfield(m, s)
        if x isa Module
            if istoplevelmodule(x)
                cache[s] = VarRef(x)
            elseif m === parentmodule(x)
                cache[s] = getmoduletree(x, amn, visited)
            else
                cache[s] = VarRef(x)
            end
        end
    end
    for n in amn
        if n !== nameof(m) && isdefined(m, n)
            x = getfield(m, n)
            if x isa Module
                if !haskey(cache, n)
                    cache[n] = VarRef(x)
                end
                if x !== Main && usedby(m, x)
                    push!(cache.used_modules, n)
                end
            end
        end
    end
    cache
end

function getenvtree(names = nothing)
    amn = allmodulenames()
    EnvStore(nameof(m) => getmoduletree(m, amn) for m in Base.loaded_modules_array() if names === nothing || nameof(m) in names)
end

# faster and more correct split_module_names
all_names(m) = all_names(m, x -> isdefined(m, x))
function all_names(m, pred, symbols = Set(Symbol[]), seen = Set(Module[]))
    push!(seen, m)
    ns = unsorted_names(m; all = true, imported = false)
    for n in ns
        isdefined(m, n) || continue
        Base.isdeprecated(m, n) && continue
        val = getfield(m, n)
        if val isa Module && !(val in seen)
            all_names(val, pred, symbols, seen)
        end
        if pred(n)
            push!(symbols, n)
        end
    end
    symbols
end

function symbols(env::EnvStore, m::Union{Module,Nothing} = nothing, allnames::Base.IdSet{Symbol} = getallns(), visited = Base.IdSet{Module}();  get_return_type = false)
    if m isa Module
        cache = _lookup(VarRef(m), env, true)
        cache === nothing && return
        push!(visited, m)
        ns = all_names(m)
        for s in ns
            !isdefined(m, s) && continue
            x = getfield(m, s)
            if Base.unwrap_unionall(x) isa DataType # Unions aren't handled here.
                if parentmodule((x)) === m
                    cache[s] = DataTypeStore(x, s, m, s in getnames(m))
                    cache_methods(x, s, env, get_return_type)
                elseif nameof(x) !== s
                    # This needs some finessing.
                    cache[s] = DataTypeStore(x, s, m, s in getnames(m))
                    ms = cache_methods(x, s, env, get_return_type)
                    # A slightly difficult case. `s` is probably a shadow binding of `x` but we should store the methods nonetheless.
                    # Example: DataFrames.Not points to InvertedIndices.InvertedIndex
                    for m in ms
                        push!(cache[s].methods, m[2])
                    end
                else
                    # These are imported variables that are reexported.
                    cache[s] = VarRef(VarRef(parentmodule(x)), nameof(x))
                end
            elseif x isa Function
                if parentmodule(x) === m || (x isa Core.IntrinsicFunction && m === Core.Intrinsics)
                    cache[s] = FunctionStore(x, s, m, s in getnames(m))
                    cache_methods(x, s, env, get_return_type)
                elseif !haskey(cache, s)
                    # This will be replaced at a later point by a FunctionStore if methods for `x` are defined within `m`.
                    if x isa Core.IntrinsicFunction
                        cache[s] = VarRef(VarRef(Core.Intrinsics), nameof(x))
                    else
                        cache[s] = VarRef(VarRef(parentmodule(x)), nameof(x))
                    end
                elseif !((cache[s] isa FunctionStore || cache[s] isa DataTypeStore) && !isempty(cache[s].methods))
                    # These are imported variables that are reexported.
                    # We don't want to remove Func/DT stores that have methods (these will be specific to the module)
                    if x isa Core.IntrinsicFunction
                        cache[s] = VarRef(VarRef(Core.Intrinsics), nameof(x))
                    else
                        cache[s] = VarRef(VarRef(parentmodule(x)), nameof(x))
                    end
                end
            elseif x isa Module
                if x === m
                    cache[s] = VarRef(x)
                elseif parentmodule(x) === m
                    symbols(env, x, allnames, visited, get_return_type = get_return_type)
                else
                    cache[s] = VarRef(x)
                end
            else
                cache[s] = GenericStore(VarRef(VarRef(m), s), FakeTypeName(typeof(x)), _doc(Base.Docs.Binding(m, s)), s in getnames(m))
            end
        end
    else
        for m in Base.loaded_modules_array()
            in(m, visited) || symbols(env, m, allnames, visited, get_return_type = get_return_type)
        end
    end
end


function load_core(; get_return_type = false)
    c = Pkg.Types.Context()
    cache = getenvtree([:Core,:Base])
    symbols(cache, get_return_type = get_return_type)
    cache[:Main] = ModuleStore(VarRef(nothing, :Main), Dict(), "", true, [], [])

    # This is wrong. As per the docs the Base.include each module should have it's own
    # version.
    push!(cache[:Base].exportednames, :include)

    # Add special cases for built-ins
    let f = cache[:Base][:include]
        cache[:Base][:include] = FunctionStore(f.name, cache[:Base][:MainInclude][:include].methods, f.doc, f.extends, true)
    end

    cache[:Base][Symbol("@.")] = cache[:Base][Symbol("@__dot__")]
    cache[:Core][:Main] = GenericStore(VarRef(nothing, :Main), FakeTypeName(Module), _doc(Base.Docs.Binding(Main, :Main)), true)
    # Add built-ins
    builtins = Symbol[nameof(getfield(Core, n).instance) for n in unsorted_names(Core, all = true) if isdefined(Core, n) && getfield(Core, n) isa DataType && isdefined(getfield(Core, n), :instance) && getfield(Core, n).instance isa Core.Builtin]
    cnames = unsorted_names(Core)
    for f in builtins
        if !haskey(cache[:Core], f)
            cache[:Core][f] = FunctionStore(getfield(Core, Symbol(f)), Symbol(f), Core, Symbol(f) in cnames)
        end
    end
    haskey(cache[:Core], :_typevar) && push!(cache[:Core][:_typevar].methods, MethodStore(:_typevar, :Core, "built-in", 0, [:n => FakeTypeName(Symbol), :lb => FakeTypeName(Any), :ub => FakeTypeName(Any)], Symbol[], FakeTypeName(Any)))
    push!(cache[:Core][:_apply].methods, MethodStore(:_apply, :Core, "built-in", 0, [:f => FakeTypeName(Function), :args => FakeTypeName(Vararg{Any})], Symbol[], FakeTypeName(Any)))
    haskey(cache[:Core].vals, :_apply_iterate) && push!(cache[:Core][:_apply_iterate].methods, MethodStore(:_apply_iterate, :Core, "built-in", 0, [:f => FakeTypeName(Function), :args => FakeTypeName(Vararg{Any})], Symbol[], FakeTypeName(Any)))
    if isdefined(Core, :_call_latest)
        push!(cache[:Core][:_call_latest].methods, MethodStore(:_call_latest, :Core, "built-in", 0, [:f => FakeTypeName(Function), :args => FakeTypeName(Vararg{Any})], Symbol[], FakeTypeName(Any)))
        push!(cache[:Core][:_call_in_world].methods, MethodStore(:_call_in_world, :Core, "built-in", 0, [:world => FakeTypeName(UInt), :f => FakeTypeName(Function), :args => FakeTypeName(Vararg{Any})], Symbol[], FakeTypeName(Any)))
    else
        if isdefined(Core, :_apply_in_world)
            push!(cache[:Core][:_apply_in_world].methods, MethodStore(:_apply_in_world, :Core, "built-in", 0, [:world => FakeTypeName(UInt), :f => FakeTypeName(Function), :args => FakeTypeName(Any)], Symbol[], FakeTypeName(Any)))
        end
        push!(cache[:Core][:_apply_latest].methods, MethodStore(:_apply_latest, :Core, "built-in", 0, [:f => FakeTypeName(Function), :args => FakeTypeName(Any)], Symbol[], FakeTypeName(Any)))
    end
    push!(cache[:Core][:_apply_pure].methods, MethodStore(:_apply_pure, :Core, "built-in", 0, [:f => FakeTypeName(Function), :args => FakeTypeName(Vararg{Any})], Symbol[], FakeTypeName(Any)))
    push!(cache[:Core][:_expr].methods, MethodStore(:_expr, :Core, "built-in", 0, [:head => FakeTypeName(Symbol), :args => FakeTypeName(Vararg{Any})], Symbol[], FakeTypeName(Expr)))
    haskey(cache[:Core].vals, :_typevar) && push!(cache[:Core][:_typevar].methods, MethodStore(:_typevar, :Core, "built-in", 0, [:name => FakeTypeName(Symbol), :lb => FakeTypeName(Any), :ub => FakeTypeName(Any)], Symbol[], FakeTypeName(TypeVar)))
    push!(cache[:Core][:applicable].methods, MethodStore(:applicable, :Core, "built-in", 0, [:f => FakeTypeName(Function), :args => FakeTypeName(Vararg{Any})], Symbol[], FakeTypeName(Bool)))
    push!(cache[:Core][:apply_type].methods, MethodStore(:apply_type, :Core, "built-in", 0, [:T => FakeTypeName(UnionAll), :types => FakeTypeName(Vararg{Any})], Symbol[], FakeTypeName(UnionAll)))
    push!(cache[:Core][:arrayref].methods, MethodStore(:arrayref, :Core, "built-in", 0, [:a => FakeTypeName(Any), :b => FakeTypeName(Any), :c => FakeTypeName(Any)], Symbol[], FakeTypeName(Any)))
    push!(cache[:Core][:arrayset].methods, MethodStore(:arrayset, :Core, "built-in", 0, [:a => FakeTypeName(Any), :b => FakeTypeName(Any), :c => FakeTypeName(Any), :d => FakeTypeName(Any)], Symbol[], FakeTypeName(Any)))
    push!(cache[:Core][:arraysize].methods, MethodStore(:arraysize, :Core, "built-in", 0, [:a => FakeTypeName(Array), :i => FakeTypeName(Int)], Symbol[], FakeTypeName(Int)))
    haskey(cache[:Core], :const_arrayref) && push!(cache[:Core][:const_arrayref].methods, MethodStore(:const_arrayref, :Core, "built-in", 0, [:args => FakeTypeName(Vararg{Any})], Symbol[], FakeTypeName(Any)))
    push!(cache[:Core][:fieldtype].methods, MethodStore(:fieldtype, :Core, "built-in", 0, [:t => FakeTypeName(DataType), :field => FakeTypeName(Symbol)], Symbol[], FakeTypeName(Type{T} where T)))
    push!(cache[:Core][:getfield].methods, MethodStore(:setfield, :Core, "built-in", 0, [:object => FakeTypeName(Any), :item => FakeTypeName(Any)], Symbol[], FakeTypeName(Any)))
    push!(cache[:Core][:ifelse].methods, MethodStore(:ifelse, :Core, "built-in", 0, [:condition => FakeTypeName(Bool), :x => FakeTypeName(Any), :y => FakeTypeName(Any)], Symbol[], FakeTypeName(Any)))
    push!(cache[:Core][:invoke].methods, MethodStore(:invoke, :Core, "built-in", 0, [:f => FakeTypeName(Function), :x => FakeTypeName(Any), :argtypes => FakeTypeName(Type{T} where T) , :args => FakeTypeName(Vararg{Any})], Symbol[], FakeTypeName(Any)))
    push!(cache[:Core][:isa].methods, MethodStore(:isa, :Core, "built-in", 0, [:a => FakeTypeName(Any), :T => FakeTypeName(Type{T} where T)], Symbol[], FakeTypeName(Bool)))
    push!(cache[:Core][:isdefined].methods, MethodStore(:getproperty, :Core, "built-in", 0, [:value => FakeTypeName(Any), :field => FakeTypeName(Any)], Symbol[], FakeTypeName(Any)))
    push!(cache[:Core][:nfields].methods, MethodStore(:nfields, :Core, "built-in", 0, [:x => FakeTypeName(Any)], Symbol[], FakeTypeName(Int)))
    push!(cache[:Core][:setfield!].methods, MethodStore(:setfield!, :Core, "built-in", 0, [:value => FakeTypeName(Any), :name => FakeTypeName(Symbol), :x => FakeTypeName(Any)], Symbol[], FakeTypeName(Any)))
    push!(cache[:Core][:sizeof].methods, MethodStore(:sizeof, :Core, "built-in", 0, [:obj => FakeTypeName(Any)], Symbol[], FakeTypeName(Int)))
    push!(cache[:Core][:svec].methods, MethodStore(:svec, :Core, "built-in", 0, [:args => FakeTypeName(Vararg{Any})], Symbol[], FakeTypeName(Any)))
    push!(cache[:Core][:throw].methods, MethodStore(:throw, :Core, "built-in", 0, [:e => FakeTypeName(Any)], Symbol[], FakeTypeName(Any)))
    push!(cache[:Core][:tuple].methods, MethodStore(:tuple, :Core, "built-in", 0, [:args => FakeTypeName(Vararg{Any})], Symbol[], FakeTypeName(Any)))
    push!(cache[:Core][:typeassert].methods, MethodStore(:typeassert, :Core, "built-in", 0, [:x => FakeTypeName(Any), :T => FakeTypeName(Type{T} where T)], Symbol[], FakeTypeName(Any)))
    push!(cache[:Core][:typeof].methods, MethodStore(:typeof, :Core, "built-in", 0, [:x => FakeTypeName(Any)], Symbol[], FakeTypeName(Type{T} where T)))

    push!(cache[:Core][:getproperty].methods, MethodStore(:getproperty, :Core, "built-in", 0, [:value => FakeTypeName(Any), :name => FakeTypeName(Symbol)], Symbol[], FakeTypeName(Any)))
    push!(cache[:Core][:setproperty!].methods, MethodStore(:setproperty!, :Core, "built-in", 0, [:value => FakeTypeName(Any), :name => FakeTypeName(Symbol), :x => FakeTypeName(Any)], Symbol[], FakeTypeName(Any)))
    push!(cache[:Core][:setproperty!].methods, MethodStore(:setproperty!, :Core, "built-in", 0, [:value => FakeTypeName(Any), :name => FakeTypeName(Symbol), :x => FakeTypeName(Any)], Symbol[], FakeTypeName(Any)))
    haskey(cache[:Core], :_abstracttype) && push!(cache[:Core][:_abstracttype].methods, MethodStore(:_abstracttype, :Core, "built-in", 0, [:m => FakeTypeName(Module), :x => FakeTypeName(Symbol), :p => FakeTypeName(Core.SimpleVector)], Symbol[], FakeTypeName(Any)))
    haskey(cache[:Core], :_primitivetype) && push!(cache[:Core][:_primitivetype].methods, MethodStore(:_primitivetype, :Core, "built-in", 0, [:m => FakeTypeName(Module), :x => FakeTypeName(Symbol), :p => FakeTypeName(Core.SimpleVector), :n => FakeTypeName(Core.Int)], Symbol[], FakeTypeName(Any)))
    haskey(cache[:Core], :_equiv_typedef) && push!(cache[:Core][:_equiv_typedef].methods, MethodStore(:_equiv_typedef, :Core, "built-in", 0, [:a => FakeTypeName(Any), :b => FakeTypeName(Any)], Symbol[], FakeTypeName(Any)))
    haskey(cache[:Core], :_setsuper!) && push!(cache[:Core][:_setsuper!].methods, MethodStore(:_setsuper!, :Core, "built-in", 0, [:a => FakeTypeName(Any), :b => FakeTypeName(Any)], Symbol[], FakeTypeName(Any)))
    haskey(cache[:Core], :_structtype) && push!(cache[:Core][:_structtype].methods, MethodStore(:_structtype, :Core, "built-in", 0, [:m => FakeTypeName(Module), :x => FakeTypeName(Symbol), :p => FakeTypeName(Core.SimpleVector), :fields => FakeTypeName(Core.SimpleVector), :mut => FakeTypeName(Bool), :z => FakeTypeName(Any)], Symbol[], FakeTypeName(Any)))
    haskey(cache[:Core], :_typebody) && push!(cache[:Core][:_typebody!].methods, MethodStore(:_typebody!, :Core, "built-in", 0, [:a => FakeTypeName(Any), :b => FakeTypeName(Any)], Symbol[], FakeTypeName(Any)))
    push!(cache[:Core][:(===)].methods, MethodStore(:(===), :Core, "built-in", 0, [:a => FakeTypeName(Any), :b => FakeTypeName(Any)], Symbol[], FakeTypeName(Any)))
    push!(cache[:Core][:(<:)].methods, MethodStore(:(<:), :Core, "built-in", 0, [:a => FakeTypeName(Type{T} where T), :b => FakeTypeName(Type{T} where T)], Symbol[], FakeTypeName(Any)))
    # Add unspecified methods for Intrinsics, working out the actual methods will need to be done by hand?
    for n in names(Core.Intrinsics)
        if getfield(Core.Intrinsics, n) isa Core.IntrinsicFunction
            push!(cache[:Core][:Intrinsics][n].methods, MethodStore(n, :Intrinsics, "built-in", 0, [:args => FakeTypeName(Vararg{Any})], Symbol[], FakeTypeName(Any)))
            :args => FakeTypeName(Vararg{Any})
        end
    end

    for bi in builtins
        if haskey(cache[:Core], bi) && isempty(cache[:Core][bi].methods)
            # Add at least one arbitrary method for anything left over
            push!(cache[:Core][bi].methods, MethodStore(bi, :none, "built-in", 0, [:x => FakeTypeName(Vararg{Any})], Symbol[], FakeTypeName(Any)))
        end
    end

    cache[:Core][:ccall] = FunctionStore(VarRef(VarRef(Core), :ccall),
        MethodStore[
            MethodStore(:ccall, :Core, "built-in", 0, [:args => FakeTypeName(Vararg{Any})], Symbol[], FakeTypeName(Any)) # General method - should be fixed
        ],
        "`ccall((function_name, library), returntype, (argtype1, ...), argvalue1, ...)`\n`ccall(function_name, returntype, (argtype1, ...), argvalue1, ...)`\n`ccall(function_pointer, returntype, (argtype1, ...), argvalue1, ...)`\n\nCall a function in a C-exported shared library, specified by the tuple (`function_name`, `library`), where each component is either a string or symbol. Instead of specifying a library, one\ncan also use a `function_name` symbol or string, which is resolved in the current process. Alternatively, `ccall` may also be used to call a function pointer `function_pointer`, such as one\nreturned by `dlsym`.\n\nNote that the argument type tuple must be a literal tuple, and not a tuple-valued variable or expression.\n\nEach `argvalue` to the `ccall` will be converted to the corresponding `argtype`, by automatic insertion of calls to `unsafe_convert(argtype, cconvert(argtype, argvalue))`. (See also the documentation for `unsafe_convert` and `cconvert` for further details.) In most cases, this simply results in a call to `convert(argtype, argvalue)`.",
        VarRef(VarRef(Core), :ccall),
        true)
    push!(cache[:Core].exportednames, :ccall)
    cache[:Core][Symbol("@__doc__")] = FunctionStore(VarRef(VarRef(Core), Symbol("@__doc__")), [], "", VarRef(VarRef(Core), Symbol("@__doc__")), true)
    cache_methods(getfield(Core, Symbol("@__doc__")), Symbol("@__doc__"), cache, false)
    # Accounts for the dd situation where Base.rand only has methods from Random which doesn't appear to be explicitly used.
    # append!(cache[:Base][:rand].methods, cache_methods(Base.rand, cache))
    for m in cache_methods(Base.rand, :rand, cache, get_return_type)
        push!(cache[:Base][:rand].methods, m[2])
    end
    for m in cache_methods(Base.randn, :randn, cache, get_return_type)
        push!(cache[:Base][:randn].methods, m[2])
    end

    # Intrinsics
    cache[:Core][:add_int] = VarRef(VarRef(VarRef(nothing, :Core), :Intrinsics), :add_int)
    cache[:Core][:sle_int] = VarRef(VarRef(VarRef(nothing, :Core), :Intrinsics), :sle_int)
    return cache
end


function collect_extended_methods(depot::EnvStore, extendeds = Dict{VarRef,Vector{VarRef}}())
    for m in depot
        collect_extended_methods(m[2], extendeds, m[2].name)
    end
    extendeds
end

function collect_extended_methods(mod::ModuleStore, extendeds, mname)
    for (n, v) in mod.vals
        if (v isa FunctionStore) && v.extends != v.name
            haskey(extendeds, v.extends) ? push!(extendeds[v.extends], mname) : (extendeds[v.extends] = VarRef[v.extends.parent, mname])
        elseif v isa ModuleStore
            collect_extended_methods(v, extendeds, v.name)
        end
    end
end

getallns() = let allns = Base.IdSet{Symbol}(); oneverything((m, s, x, state) -> push!(allns, s)); allns end

"""
    split_module_names(m::Module, allns)

Return two lists of names accessible from calling getfield(m, somename)`. The first
contains those symbols returned by `Base.names(m, all = true)`. The second contains
all others, including imported symbols and those introduced by the `using` of modules.
"""
function split_module_names(m::Module, allns)
    internal_names = getnames(m)
    availablenames = Set{Symbol}([s for s in allns if isdefined(m, s)])
    # usinged_names = Set{Symbol}()

    for n in availablenames
        if (n in internal_names)
            pop!(availablenames, n)
        end
    end
    allms = get_all_modules()
    for u in get_used_modules(m, allms)
        for n in unsorted_names(u)
            if n in availablenames
                pop!(availablenames, n)
                # push!(usinged_names, pop!(availablenames, n))
            end
        end
    end
    internal_names, availablenames
end

get_all_modules() = let allms = Base.IdSet{Module}(); apply_to_everything(x -> if x isa Module push!(allms, x) end); allms end
get_used_modules(M, allms = get_all_modules()) = [m for m in allms if usedby(M, m)]
