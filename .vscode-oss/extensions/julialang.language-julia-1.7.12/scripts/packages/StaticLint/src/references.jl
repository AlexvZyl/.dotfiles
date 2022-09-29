function setref!(x::EXPR, binding::Binding)
    if !hasmeta(x)
        x.meta = Meta()
    end
    x.meta.ref = binding
    push!(binding.refs, x)
end

function setref!(x::EXPR, binding)
    if !hasmeta(x)
        x.meta = Meta()
    end
    x.meta.ref = binding
end


# Main function to be called. Given the `state` tries to determine what `x`
# refers to. If it remains unresolved and is in a delayed evaluation scope
# (i.e. a function) it gets pushed to list (.urefs) to be resolved after we've
# run over the entire top-level scope.
function resolve_ref(x, state)
    if !(parentof(x) isa EXPR && headof(parentof(x)) === :quotenode)
        resolve_ref(x, state.scope, state)
    end
end


# The first method that is tried. Searches the current scope for local bindings
# that match `x`. Steps:
# 1. Check whether we've already checked this scope (inifinite loops are
# possible when traversing nested modules.)
# 2. Check what sort of EXPR we're dealing with, separate name from EXPR that
# binds.
# 3. Look in the scope's variable list for a binding matching the name.
# 4. If 3. is unsuccessful, check whether the scope imports any modules then check them.
# 5. If no match is found within this scope check the parent scope.
# The return value is a boolean that is false if x should point to something but
# can't be resolved.

function resolve_ref(x::EXPR, scope::Scope, state::State)::Bool
    # if the current scope is a soft scope we should check the parent scope first
    # before trying to resolve the ref locally
    # if is_soft_scope(scope) && parentof(scope) isa Scope
    #     resolve_ref(x, parentof(scope), state) && return true
    # end

    hasref(x) && return true
    resolved = false

    if is_getfield(x)
        return resolve_getfield(x, scope, state)
    elseif iskwarg(x)
        # Note to self: this seems wronge - Binding should be attached to entire Kw EXPR.
        if isidentifier(x.args[1]) && !hasbinding(x.args[1])
            setref!(x.args[1], Binding(x.args[1], nothing, nothing, []))
        elseif isdeclaration(x.args[1]) && isidentifier(x.args[1].args[1]) && !hasbinding(x.args[1].args[1])
            if hasbinding(x.args[1])
                setref!(x.args[1].args[1], bindingof(x.args[1]))
            else
                setref!(x.args[1].args[1], Binding(x.args[1], nothing, nothing, []))
            end
        end
        return true
    elseif is_special_macro_term(x) || new_within_struct(x)
        setref!(x, Binding(noname, nothing, nothing, []))
        return true
    end
    mn = nameof_expr_to_resolve(x)
    mn === nothing && return true

    if scopehasbinding(scope, mn)
        setref!(x, scope.names[mn])
        resolved = true
    elseif scope.modules isa Dict && length(scope.modules) > 0
        for m in values(scope.modules)
            resolved = resolve_ref_from_module(x, m, state)
            resolved && return true
        end
    end
    if !resolved && !CSTParser.defines_module(scope.expr) && parentof(scope) isa Scope
        return resolve_ref(x, parentof(scope), state)
    end
    return resolved
end

# Searches a module store for a binding/variable that matches the reference `x1`.
function resolve_ref_from_module(x1::EXPR, m::SymbolServer.ModuleStore, state::State)::Bool
    hasref(x1) && return true

    if CSTParser.ismacroname(x1)
        x = x1
        if valof(x) == "@." && m.name == VarRef(nothing, :Base)
            # @. gets converted to @__dot__, probably during lowering.
            setref!(x, m[:Broadcast][Symbol("@__dot__")])
            return true
        end

        mn = Symbol(valof(x))
        if isexportedby(mn, m)
            setref!(x, maybe_lookup(m[mn], state))
            return true
        end
    elseif isidentifier(x1)
        x = x1
        if Symbol(valof(x)) == m.name.name
            setref!(x, m)
            return true
        elseif isexportedby(x, m)
            setref!(x, maybe_lookup(m[Symbol(valof(x))], state))
            return true
        end
    end
    return false
end

function resolve_ref_from_module(x::EXPR, scope::Scope, state::State)::Bool
    hasref(x) && return true
    resolved = false

    mn = nameof_expr_to_resolve(x)
    mn === nothing && return true

    if scope_exports(scope, mn, state)
        setref!(x, scope.names[mn])
        resolved = true
    end
    return resolved
end

"""
    scope_exports(scope::Scope, name::String)

Does the scope export a variable called `name`?
"""
function scope_exports(scope::Scope, name::String, state)
    if scopehasbinding(scope, name) && (b = scope.names[name]) isa Binding
        initial_pass_on_exports(scope.expr, name, state)
        for ref in b.refs
            if ref isa EXPR && parentof(ref) isa EXPR && headof(parentof(ref)) === :export
                return true
            end
        end
    end
    return false
end

"""
    initial_pass_on_exports(x::EXPR, server)

Export statements need to be (pseudo) evaluated each time we consider
whether a variable is made available by an import statement.
"""

function initial_pass_on_exports(x::EXPR, name, state)
    for a in x.args[3] # module block expressions
        if headof(a) === :export
            for i = 1:length(a.args)
                if isidentifier(a.args[i]) && valof(a.args[i]) == name && !hasref(a.args[i])
                    Delayed(scopeof(x), state.env, state.server)(a.args[i])
                end
            end
        end
    end
end

# Fallback method
function resolve_ref(x::EXPR, m, state::State)::Bool
    return hasref(x)::Bool
end

rhs_of_getfield(x::EXPR) = CSTParser.is_getfield_w_quotenode(x) ? x.args[2].args[1] : x
lhs_of_getfield(x::EXPR) = rhs_of_getfield(x.args[1])

"""
    resolve_getfield(x::EXPR, parent::Union{EXPR,Scope,ModuleStore,Binding}, state::State)::Bool

Given an expression of the form `parent.x` try to resolve `x`. The method
called with `parent::EXPR` resolves the reference for `parent`, other methods
then check whether the Binding/Scope/ModuleStore to which `parent` points has
a field matching `x`.
"""
function resolve_getfield(x::EXPR, scope::Scope, state::State)::Bool
    hasref(x) && return true
    resolved = resolve_ref(x.args[1], scope, state)
    if isidentifier(x.args[1])
        lhs = x.args[1]
    elseif CSTParser.is_getfield_w_quotenode(x.args[1])
        lhs = lhs_of_getfield(x)
    else
        return resolved
    end
    if resolved && (rhs = rhs_of_getfield(x)) !== nothing
        resolved = resolve_getfield(rhs, refof(lhs), state)
    end
    return resolved
end


function resolve_getfield(x::EXPR, parent_type::EXPR, state::State)::Bool
    hasref(x) && return true
    resolved = false
    if isidentifier(x)
        if CSTParser.defines_module(parent_type) && scopeof(parent_type) isa Scope
            resolved = resolve_ref(x, scopeof(parent_type), state)
        elseif CSTParser.defines_struct(parent_type)
            if scopehasbinding(scopeof(parent_type), valof(x))
                setref!(x, scopeof(parent_type).names[valof(x)])
                resolved = true
            end
        end
    end
    return resolved
end


function resolve_getfield(x::EXPR, b::Binding, state::State)::Bool
    hasref(x) && return true
    resolved = false
    if b.val isa Binding
        resolved = resolve_getfield(x, b.val, state)
    elseif b.val isa SymbolServer.ModuleStore || (b.val isa EXPR && CSTParser.defines_module(b.val))
        resolved = resolve_getfield(x, b.val, state)
    elseif b.type isa Binding
        resolved = resolve_getfield(x, b.type.val, state)
    elseif b.type isa SymbolServer.DataTypeStore
        resolved = resolve_getfield(x, b.type, state)
    end
    return resolved
end

function resolve_getfield(x::EXPR, parent_type, state::State)::Bool
    hasref(x)
end

function is_overloaded(val::SymbolServer.SymStore, scope::Scope)
    vr = val.name isa SymbolServer.FakeTypeName ? val.name.name : val.name
    haskey(scope.overloaded, vr)
end

function resolve_getfield(x::EXPR, m::SymbolServer.ModuleStore, state::State)::Bool
    hasref(x) && return true
    resolved = false
    if CSTParser.ismacroname(x) && (val = maybe_lookup(SymbolServer.maybe_getfield(Symbol(valofid(x)), m, getsymbols(state)), state)) !== nothing
        setref!(x, val)
        resolved = true
    elseif isidentifier(x) && (val = maybe_lookup(SymbolServer.maybe_getfield(Symbol(valofid(x)), m, getsymbols(state)), state)) !== nothing
        # Check whether variable is overloaded in top-level scope
        tls = retrieve_toplevel_scope(state.scope)
        # if tls.overloaded !== nothing && (vr = val.name isa SymbolServer.FakeTypeName ? val.name.name : val.name; haskey(tls.overloaded, vr))
        #     @info 1
        #     setref!(x, tls.overloaded[vr])
        #     return true
        # end
        vr = val.name isa SymbolServer.FakeTypeName ? val.name.name : val.name
        if haskey(tls.names, valof(x)) && tls.names[valof(x)] isa Binding && tls.names[valof(x)].val isa SymbolServer.FunctionStore
            setref!(x, tls.names[valof(x)])
            return true
        elseif tls.overloaded !== nothing && haskey(tls.overloaded, vr)
            setref!(x, tls.overloaded[vr])
            return true
        end
        setref!(x, val)
        resolved = true
    end
    return resolved
end

function resolve_getfield(x::EXPR, parent::SymbolServer.DataTypeStore, state::State)::Bool
    hasref(x) && return true
    resolved = false
    if isidentifier(x) && Symbol(valof(x)) in parent.fieldnames
        fi = findfirst(f -> Symbol(valof(x)) == f, parent.fieldnames)
        ft = parent.types[fi]
        val = SymbolServer._lookup(ft, getsymbols(state), true)
        # TODO: Need to handle the case where we get back a FakeUnion, etc.
        setref!(x, Binding(noname, nothing, val, []))
        resolved = true
    end
    return resolved
end

resolvable_macroname(x::EXPR) = isidentifier(x) && CSTParser.ismacroname(x) && refof(x) === nothing

nameof_expr_to_resolve(x) = isidentifier(x) ? valofid(x) : nothing

"""
    valofid(x)

Returns the string value of an expression for which `isidentifier` is true,
i.e. handles NONSTDIDENTIFIERs.
"""
valofid(x::EXPR) = headof(x) === :IDENTIFIER ? valof(x) : valof(x.args[2])

"""
new_within_struct(x::EXPR)

Checks whether x is a reference to `new` within a datatype constructor.
"""
new_within_struct(x::EXPR) = isidentifier(x) && valofid(x) == "new" && is_in_fexpr(x, CSTParser.defines_struct)
is_special_macro_term(x::EXPR) = isidentifier(x) && (valofid(x) == "__source__" || valofid(x) == "__module__") && is_in_fexpr(x, CSTParser.defines_macro)
