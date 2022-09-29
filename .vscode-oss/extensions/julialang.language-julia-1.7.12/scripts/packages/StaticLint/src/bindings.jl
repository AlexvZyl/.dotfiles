"""
Bindings indicate that an `EXPR` _may_ introduce a new name into the current scope/namespace.
Struct fields:
* `name`: the `EXPR` that defines the unqualifed name of the binding.
* `val`: what the binding points to, either a `Binding` (indicating ..), `EXPR` (this is generally the expression that defines the value) or `SymStore`.
* `type`: the type of the binding, either a `Binding`, `EXPR`, or `SymStore`.
* `refs`: a list containing all references that have been made to the binding.
"""
mutable struct Binding
    name::EXPR
    val::Union{Binding,EXPR,SymbolServer.SymStore,Nothing}
    type::Union{Binding,SymbolServer.SymStore,Nothing}
    refs::Vector{Any}
end
Binding(x::EXPR) = Binding(CSTParser.get_name(x), x, nothing, [])

function Base.show(io::IO, b::Binding)
    printstyled(io, " Binding(", to_codeobject(b.name),
        b.type === nothing ? "" : ":: ",
        b.refs isa Vector ? "($(length(b.refs)) refs))" : ")", color=:blue)
end


hasbinding(x::EXPR) = hasmeta(x) && hasbinding(x.meta)
bindingof(x) = nothing
bindingof(x::EXPR) = bindingof(x.meta)


hasref(x::EXPR) = hasmeta(x) && hasref(x.meta)
refof(x::EXPR) = hasmeta(x) ? x.meta.ref : nothing


function gotoobjectofref(x::EXPR)
    r = refof(x)
    if r isa SymbolServer.SymStore
        return r
    elseif r isa Binding

    end
end


"""
    mark_bindings!(x::EXPR, state)

Checks whether the expression `x` should introduce new names and marks them as needed. Generally this marks expressions that would introdce names to the current scope (i.e. that x sits in) but in cases marks expressions that will add names to lower scopes. This is done when it is not knowable that a child node of `x` will introduce a new name without the context of where it sits in `x` -for example the arguments of the signature of a function definition.
"""
function mark_bindings!(x::EXPR, state)
    if hasbinding(x)
        return
    end
    if !hasmeta(x)
        x.meta = Meta()
    end
    if isassignment(x)
        if CSTParser.is_func_call(x.args[1])
            name = CSTParser.get_name(x)
            mark_binding!(x)
            mark_sig_args!(x.args[1])
        elseif CSTParser.iscurly(x.args[1])
            mark_typealias_bindings!(x)
        elseif !is_getfield(x.args[1]) && state.flags & NO_NEW_BINDINGS == 0
            mark_binding!(x.args[1], x)
        end
    elseif CSTParser.defines_anon_function(x)
        mark_binding!(x.args[1], x)
    elseif CSTParser.iswhere(x)
        for i = 2:length(x.args)
            mark_binding!(x.args[i])
        end
    elseif headof(x) === :for
        markiterbinding!(x.args[2])
    elseif headof(x) === :generator || headof(x) === :filter
        for i = 2:length(x.args)
            markiterbinding!(x.args[i])
        end
    elseif headof(x) === :do
        for i in 1:length(x.args[2].args)
            mark_binding!(x.args[2].args[i])
        end
    elseif headof(x) === :function || headof(x) === :macro
        name = CSTParser.get_name(x)
        x.meta.binding = Binding(name, x, CoreTypes.Function, [])
        if isidentifier(name) && headof(x) === :macro
            setref!(name, bindingof(x))
        end
        mark_sig_args!(CSTParser.get_sig(x))
    elseif CSTParser.defines_module(x)
        x.meta.binding = Binding(x.args[2], x, CoreTypes.Module, [])
        setref!(x.args[2], bindingof(x))
    elseif headof(x) === :try && isidentifier(x.args[2])
        mark_binding!(x.args[2])
        setref!(x.args[2], bindingof(x.args[2]))
    elseif CSTParser.defines_datatype(x)
        name = CSTParser.get_name(x)
        x.meta.binding = Binding(name, x, CoreTypes.DataType, [])
        kwdef = parentof(x) isa EXPR && _points_to_Base_macro(parentof(x).args[1], Symbol("@kwdef"), state)
        if isidentifier(name)
            setref!(name, bindingof(x))
        end
        mark_parameters(CSTParser.get_sig(x))
        if CSTParser.defines_struct(x) # mark field block
            for arg in x.args[3].args
                CSTParser.defines_function(arg) && continue
                if kwdef && CSTParser.isassignment(arg) || arg.head === :const
                    arg = arg.args[1]
                end
                mark_binding!(arg)
            end
        end
    elseif headof(x) === :local
        for i = 1:length(x.args)
            if isidentifier(x.args[i])
                mark_binding!(x.args[i])
                setref!(x.args[i], bindingof(x.args[i]))
            end
        end
    end
end


function mark_binding!(x::EXPR, val=x)
    if CSTParser.iskwarg(x) || (CSTParser.isdeclaration(x) && CSTParser.istuple(x.args[1]))
        mark_binding!(x.args[1], x)
    elseif CSTParser.istuple(x) || CSTParser.isparameters(x)
        for arg in x.args
            mark_binding!(arg, val)
        end
    elseif CSTParser.isbracketed(x)
        mark_binding!(CSTParser.rem_invis(x), val)
    elseif CSTParser.issplat(x)
        mark_binding!(x.args[1], x)
    elseif !(isunarysyntax(x) && valof(headof(x)) == "::")
        if !hasmeta(x)
            x.meta = Meta()
        end
        x.meta.binding = Binding(CSTParser.get_name(x), val, nothing, [])
    end
    return x
end

function mark_parameters(sig::EXPR, params = String[])
    if CSTParser.issubtypedecl(sig)
        mark_parameters(sig.args[1], params)
    elseif iswhere(sig)
        for i = 2:length(sig.args)
            x = mark_binding!(sig.args[i])
            val = valof(bindingof(x).name)
            if val isa String
                push!(params, val)
            end
        end
        mark_parameters(sig.args[1], params)
    elseif CSTParser.iscurly(sig)
        for i = 2:length(sig.args)
            x = mark_binding!(sig.args[i])
            if bindingof(x) isa Binding && valof(bindingof(x).name) in params
                # Don't mark a new binding if a parameter has already been
                # introduced from a :where
                x.meta.binding = nothing
            end
        end
    end
    sig
end


function markiterbinding!(iter::EXPR)
    if CSTParser.isassignment(iter)
        mark_binding!(iter.args[1], iter)
    elseif CSTParser.iscall(iter) && CSTParser.isoperator(iter.args[1]) && (valof(iter.args[1]) == "in" || valof(iter.args[1]) == "∈")
        mark_binding!(iter.args[2], iter)
    elseif headof(iter) === :block
        for i = 1:length(iter.args)
            markiterbinding!(iter.args[i])
        end
    end
    return iter
end

function mark_sig_args!(x::EXPR)
    if CSTParser.iscall(x) || CSTParser.istuple(x)
        if x.args !== nothing && length(x.args) > 0
            if CSTParser.isbracketed(x.args[1]) && length(x.args[1].args) > 0 && CSTParser.isdeclaration(x.args[1].args[1])
                mark_binding!(x.args[1].args[1])
            end
            for i = (CSTParser.iscall(x) ? 2 : 1):length(x.args)
                a = x.args[i]
                if CSTParser.isparameters(a)
                    for j = 1:length(a.args)
                        aa = a.args[j]
                        mark_binding!(aa)
                    end
                elseif CSTParser.ismacrocall(a) && CSTParser.isidentifier(a.args[1]) && valofid(a.args[1]) == "@nospecialize" && length(a.args) == 3
                    mark_binding!(a.args[3])
                else
                    mark_binding!(a)
                end
            end
        end
    elseif CSTParser.iswhere(x)
        for i in 2:length(x.args)
            mark_binding!(x.args[i])
        end
        mark_sig_args!(x.args[1])
    elseif CSTParser.isbracketed(x)
        mark_sig_args!(x.args[1])
    elseif CSTParser.isdeclaration(x)
        mark_sig_args!(x.args[1])
    elseif CSTParser.isbinarycall(x)
        mark_binding!(x.args[1])
        mark_binding!(x.args[2])
    elseif CSTParser.isunarycall(x) && length(x.args) == 2 && (CSTParser.isbracketed(x.args[2]) || CSTParser.isdeclaration(x.args[2]))
        mark_binding!(x.args[2])
    end
end

function mark_typealias_bindings!(x::EXPR)
    if !hasmeta(x)
        x.meta = Meta()
    end
    x.meta.binding = Binding(CSTParser.get_name(x.args[1]), x, CoreTypes.DataType, [])
    setscope!(x, Scope(x))
    for i = 2:length(x.args[1].args)
        arg = x.args[1].args[i]
        if isidentifier(arg)
            mark_binding!(arg)
        elseif CSTParser.issubtypedecl(arg) && isidentifier(arg.args[1])
            mark_binding!(arg.args[1])
        end
    end
    return x
end

function is_in_funcdef(x)
    if !(parentof(x) isa EXPR)
        return false
    elseif CSTParser.iswhere(parentof(x)) || CSTParser.isbracketed(parentof(x))
        return is_in_funcdef(parentof(x))
    elseif headof(parentof(x)) === :function || CSTParser.isassignment(parentof(x))
        return true
    else
        return false
    end
end

rem_wheres_subs_decls(x::EXPR) = (iswhere(x) || isdeclaration(x) || CSTParser.issubtypedecl(x)) ? rem_wheres_subs_decls(x.args[1]) : x

function _in_func_or_struct_def(x::EXPR)
    # only called in :where
    # check 1st arg contains a call (or op call)
    ex = rem_wheres_subs_decls(x.args[1])
    is_in_fexpr(x, CSTParser.defines_struct) || ((CSTParser.iscall(ex) || CSTParser.is_getfield(ex) || CSTParser.isunarycall(ex)) && is_in_funcdef(x))
end

"""
    add_binding(x, state, scope=state.scope)

Add the binding of `x` to the current scope. Special handling is required for:
* macros: to prefix the `@`
* functions: These are added to the top-level scope unless this syntax is used to define a closure within a function. If a function with the same name already exists in the scope then it is not replaced. This enables the `refs` list of the Binding of that 'root method' to hold a method table, the name of the new function will resolve to the binding of the root method (to get a list of actual methods -`[get_method(ref) for ref in binding.refs if get_method(ref) !== nothing]`). For example
```julia
[1] f() = 1
[2] f(x) = 2
```
[1] is the root method and the name of [2] resolves to the binding of [1]. Functions declared with qualified names require special handling, there are comments in the source.

Some simple type inference is run.
"""
function add_binding(x, state, scope=state.scope)
    if bindingof(x) isa Binding
        b = bindingof(x)
        if isidentifier(b.name)
            name = valofid(b.name)
        elseif CSTParser.ismacroname(b.name) # must be getfield
            name = string(to_codeobject(b.name))
        elseif isoperator(b.name)
            name = valof(b.name)
        else
            return
        end
        # check for global marker
        if isglobal(name, scope)
            scope = _get_global_scope(state.scope)
        end

        if CSTParser.defines_macro(x)
            scope.names[string("@", name)] = b
            mn = CSTParser.get_name(x)
            if isidentifier(mn)
                setref!(mn, b)
            end
        elseif defines_function(x)
            # TODO: Need to do check that we're not in a closure.
            tls = retrieve_toplevel_or_func_scope(scope)
            tls === nothing && return @warn "top-level scope not retrieved"
            if name_is_getfield(b.name)
                resolve_ref(parentof(parentof(b.name)).args[1], scope, state)
                lhs_ref = refof_maybe_getfield(parentof(parentof(b.name)).args[1])
                if lhs_ref isa SymbolServer.ModuleStore && haskey(lhs_ref.vals, Symbol(name))
                    # Overloading
                    if haskey(tls.names, name) && eventually_overloads(tls.names[name], lhs_ref.vals[Symbol(name)], state)
                        # Though we're explicitly naming a function for overloading, it has already been imported to the toplevel scope.
                        if !hasref(b.name)
                            setref!(b.name, tls.names[name]) # Add ref to previous overload
                            overload_method(tls, b, VarRef(lhs_ref.name, Symbol(name)))
                        end
                        # Do nothing, get_name(x) will resolve to the root method
                    elseif isexportedby(name, lhs_ref)
                        # Name is already available
                        tls.names[name] = b
                        if !hasref(b.name) # Is this an appropriate indicator that we've not marked the overload?
                            push!(b.refs, maybe_lookup(lhs_ref[Symbol(name)], state))
                            setref!(b.name, b) # we actually set the rhs of the qualified name to point to this binding
                        end
                    else
                        # Mark as overloaded so that calls to `M.f()` resolve properly.
                        overload_method(tls, b, VarRef(lhs_ref.name, Symbol(name))) # Add to overloaded list but not scope.
                    end
                elseif lhs_ref isa Binding && CoreTypes.ismodule(lhs_ref.type)
                    if hasscope(lhs_ref.val) && haskey(scopeof(lhs_ref.val).names, name)
                        # Don't need to do anything, name will resolve
                    end
                end
            else
                if scopehasbinding(tls, name)

                    existing_binding = tls.names[name]
                    if existing_binding isa Binding && (existing_binding.val isa Binding || existing_binding.val isa SymbolServer.FunctionStore || existing_binding.val isa SymbolServer.DataTypeStore)
                        # Should possibly be a while statement
                        # If the .val is as above the Binding likely won't have a proper type attached
                        # so lets use the .val instead.
                        existing_binding = existing_binding.val
                    end
                    if (existing_binding isa Binding && ((CoreTypes.isfunction(existing_binding.type) || CoreTypes.isdatatype(existing_binding.type))) || existing_binding isa SymbolServer.FunctionStore || existing_binding isa SymbolServer.DataTypeStore)
                        # do nothing name of `x` will resolve to the root method
                    else
                        seterror!(x, CannotDefineFuncAlreadyHasValue)
                    end
                else
                    scope.names[name] = b
                    if !hasref(b.name)
                        setref!(b.name, b)
                    end
                end
                if CSTParser.defines_struct(scope.expr) && parentof(scope) isa Scope
                    # hoist binding for inner constructor to parent scope
                    return add_binding(x, state, parentof(scope))
                end
            end
        elseif scopehasbinding(scope, name)
            # TODO: some checks about rebinding of consts
            check_const_decl(name, b, scope)

            scope.names[name] = b
        elseif is_soft_scope(scope) && parentof(scope) isa Scope && isidentifier(b.name) && scopehasbinding(parentof(scope), valofid(b.name)) && !enforce_hard_scope(x, scope)
            add_binding(x, state, scope.parent)
        else
            scope.names[name] = b
        end
        infer_type(b, scope, state)
    elseif bindingof(x) isa SymbolServer.SymStore
        scope.names[valofid(x)] = bindingof(x)
    end
end

function enforce_hard_scope(x::EXPR, scope)
    scope.expr.head === :for && is_in_fexpr(x, x-> x == scope.expr.args[1])
end

name_is_getfield(x) = parentof(x) isa EXPR && parentof(parentof(x)) isa EXPR && CSTParser.is_getfield_w_quotenode(parentof(parentof(x)))


"""
eventually_overloads(b, x, state)


"""
eventually_overloads(b::Binding, ss::SymbolServer.SymStore, state) = b.val == ss || (b.refs !== nothing && length(b.refs) > 0 && first(b.refs) == ss)
eventually_overloads(b::Binding, ss::SymbolServer.VarRef, state) = eventually_overloads(b, maybe_lookup(ss, state), state)
eventually_overloads(b, ss, state) = false

isglobal(name, scope) = false
isglobal(name::String, scope) = scope !== nothing && scopehasbinding(scope, "#globals") && name in scope.names["#globals"].refs

function mark_globals(x::EXPR, state)
    if headof(x) === :global
        if !scopehasbinding(state.scope, "#globals")
            state.scope.names["#globals"] = Binding(EXPR(:IDENTIFIER, EXPR[], nothing, 0, 0, "#globals", nothing, nothing), nothing, nothing, [])
        end
        for i = 2:length(x.args)
            if isidentifier(x.args[i]) && !scopehasbinding(state.scope, valofid(x.args[i]))
                push!(state.scope.names["#globals"].refs, valofid(x.args[i]))
            end
        end
    end
end

function name_extends_imported_method(b::Binding)
    if CoreTypes.isfunction(b.type) && CSTParser.hasparent(b.name) && CSTParser.is_getfield(parentof(b.name))
        if refof_maybe_getfield(parentof(b.name)[1]) !== nothing

        end
    end
end
