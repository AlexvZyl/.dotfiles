mutable struct Scope
    parent::Union{Scope,Nothing}
    expr::EXPR
    names::Dict{String,Binding}
    modules::Union{Nothing,Dict{Symbol,Any}}
    overloaded::Union{Dict,Nothing}
end
Scope(expr) = Scope(nothing, expr, Dict{Symbol,Binding}(), nothing, nothing)
function Base.show(io::IO, s::Scope)
    printstyled(io, headof(s.expr))
    printstyled(io, " ", join(keys(s.names), ","), color=:yellow)
    s.modules isa Dict && printstyled(io, " ", join(keys(s.modules), ","), color=:blue)
end

function overload_method(scope::Scope, b::Binding, vr::SymbolServer.VarRef)
    if scope.overloaded === nothing
        scope.overloaded = Dict()
    end
    if haskey(scope.overloaded, vr)
        # TODO: need to check this hasn't already been done
        push!(scope.overloaded[vr].refs, b.val)
    else
        scope.overloaded[vr] = b
    end
end

"""
scopehasmodule(s::Scope, mname::Symbol)::Bool

Checks whether the module `mname` has been `using`ed in `s`.
"""
scopehasmodule(s::Scope, mname::Symbol) = s.modules !== nothing && haskey(s.modules, mname)

"""
    addmoduletoscope!(s, m, [mname::Symbol])

Adds module `m` to the list of used modules in scope `s`.
"""
function addmoduletoscope!(s::Scope, m, mname::Symbol)
    if s.modules === nothing
        s.modules = Dict{Symbol,Any}()
    end
    s.modules[mname] = m
end
addmoduletoscope!(s::Scope, m::SymbolServer.ModuleStore) = addmoduletoscope!(s, m, m.name.name)
addmoduletoscope!(s::Scope, m::EXPR) =  CSTParser.defines_module(m) && addmoduletoscope!(s, scopeof(m), Symbol(valof(CSTParser.get_name(m))))
addmoduletoscope!(s::Scope, s1::Scope) = CSTParser.defines_module(s1.expr) && addmoduletoscope!(s, s1, Symbol(valof(CSTParser.get_name(s1.expr))))


getscopemodule(s::Scope, m::Symbol) = s.modules[m]

"""
    scopehasbinding(s::Scope, n::String)

Checks whether s has a binding for variable named `n`.
"""
scopehasbinding(s::Scope, n::String) = haskey(s.names, n)

is_soft_scope(scope::Scope) = scope.expr.head == :for || scope.expr.head == :while || scope.expr.head == :try

"""
    introduces_scope(x::EXPR, state)

Does this expression introduce a new scope?
"""
function introduces_scope(x::EXPR, state)
    # TODO: remove unused 2nd argument.
    if CSTParser.isassignment(x) && (CSTParser.is_func_call(x.args[1]) || CSTParser.iscurly(x.args[1]))
        return true
    elseif CSTParser.defines_anon_function(x)
        return true
    elseif CSTParser.iswhere(x) 
        # unless in func def signature
        return !_in_func_or_struct_def(x)
    elseif CSTParser.istuple(x) && CSTParser.hastrivia(x) && ispunctuation(x.trivia[1]) && length(x.args) > 0 && isassignment(x.args[1])
        # named tuple
        return true
    elseif headof(x) === :function ||
            headof(x) === :macro ||
            headof(x) === :for ||
            headof(x) === :while ||
            headof(x) === :let ||
            headof(x) === :generator || # and Flatten?
            headof(x) === :try ||
            headof(x) === :do ||
            headof(x) === :module ||
            headof(x) === :abstract ||
            headof(x) === :primitive ||
            headof(x) === :struct
        return true
    end
    return false
end


hasscope(x::EXPR) = hasmeta(x) && hasscope(x.meta)
scopeof(x) = nothing
scopeof(x::EXPR) = scopeof(x.meta)
CSTParser.parentof(s::Scope) = s.parent

function setscope!(x::EXPR, s)
    if !hasmeta(x)
        x.meta = Meta()
    end
    x.meta.scope = s
end

"""
    scopes(x::EXPR, state)

Called when traversing the syntax tree and handles the association of
scopes with expressions. On the first pass this will add scopes as
necessary, on following passes it empties it. 
"""
function scopes(x::EXPR, state)
    clear_scope(x)
    if scopeof(x) === nothing && introduces_scope(x, state)
        setscope!(x, Scope(x))
    end
    s0 = state.scope
    if headof(x) === :file
        setscope!(x, state.scope)
        add_eval_method(x, state)
    elseif scopeof(x) isa Scope
        scopeof(x) != s0 && setparent!(scopeof(x), s0)
        state.scope = scopeof(x)
        if headof(x) === :module && headof(x.args[1]) === :TRUE # Add default modules to a new module
            state.scope.modules = Dict{Symbol,Any}() # TODO: only create new Dict if not assigned?
            state.scope.modules[:Base] = getsymbols(state)[:Base]
            state.scope.modules[:Core] = getsymbols(state)[:Core]
            add_eval_method(x, state)
        elseif headof(x) === :module && headof(x.args[1]) === :FALSE
            state.scope.modules = Dict{String,Any}()
            state.scope.modules[:Core] = getsymbols(state)[:Core]
            add_eval_method(x, state)
        end
        if headof(x) === :module && bindingof(x) !== nothing # Add reference to out of scope binding (i.e. itself)
            # state.scope.names[bindingof(x).name] = bindingof(x)
            # TODO: move this to the binding stage
            add_binding(x, state)
        # elseif headof(x) === :flatten && headof(x[1]) === CSTParser.Generator && length(x[1]) > 0 && headof(x[1][1]) === CSTParser.Generator
        #     setscope!(x[1][1], nothing)
        end
    end
    return s0
end

# Add an `eval` method
function add_eval_method(x, state)
    mod = if x.head === :module
        CSTParser.isidentifier(x.args[3]) ? Symbol(valof(x.args[3])) : :unknown
    else
        Symbol("top-level")
    end
    meth = SymbolServer.MethodStore(:eval, mod, "", 0, [:expr => SymbolServer.FakeTypeName(SymbolServer.VarRef(SymbolServer.VarRef(nothing, :Core), :Any), [])], [], Any)
    state.scope.names["eval"] = Binding(x, SymbolServer.FunctionStore(SymbolServer.VarRef(nothing, :nothing), SymbolServer.MethodStore[meth],"", SymbolServer.VarRef(nothing, :nothing), false), getsymbols(state)[:Core][:DataType], [])
end
