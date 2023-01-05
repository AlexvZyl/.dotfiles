function handle_macro(@nospecialize(x), state) end
function handle_macro(x::EXPR, state)
    !CSTParser.ismacrocall(x) && return
    if headof(x.args[1]) === :globalrefdoc
        if length(x.args) == 4
            if isidentifier(x.args[4]) && !resolve_ref(x.args[4], state)
                if state isa Toplevel
                    push!(state.resolveonly, x)
                end
            elseif CSTParser.is_func_call(x.args[4])
                sig = (x.args[4])
                if sig isa EXPR 
                    hasscope(sig) && return # We've already done this, don't repeat
                    setscope!(sig, Scope(sig))
                    mark_sig_args!(sig)                    
                end
                if state isa Toplevel
                    push!(state.resolveonly, x)
                end
            end
        end
    elseif CSTParser.ismacroname(x.args[1])
        state(x.args[1])
        if _points_to_Base_macro(x.args[1], Symbol("@deprecate"), state) && length(x.args) == 4
            if bindingof(x.args[3]) !== nothing
                return
            elseif CSTParser.is_func_call(x.args[3])
                # add deprecated method
                # add deprecated function binding and args in new scope
                mark_binding!(x.args[3], x)
                mark_sig_args!(x.args[3])
                s0 = state.scope # store previous scope
                state.scope = Scope(s0, x, Dict(), nothing, nothing)
                setscope!(x, state.scope) # tag new scope to generating expression
                state(x.args[3])
                state(x.args[4])
                state.scope = s0
            elseif isidentifier(x.args[3])
                mark_binding!(x.args[3], x)
            end
        elseif _points_to_Base_macro(x.args[1], Symbol("@deprecate_binding"), state) && length(x.args) == 4 && isidentifier(x.args[3]) && isidentifier(x.args[4])
            setref!(x.args[3], refof(x.args[4]))
        elseif _points_to_Base_macro(x.args[1], Symbol("@eval"), state) && length(x.args) == 3 && state isa Toplevel
            # Create scope around eval'ed expression. This ensures anybindings are
            # correctly hoisted to the top-level scope.
            setscope!(x, Scope(x))
            setparent!(scopeof(x), state.scope)
            s0 = state.scope
            state.scope = scopeof(x)
            interpret_eval(x.args[3], state)
            state.scope = s0
        elseif _points_to_Base_macro(x.args[1], Symbol("@irrational"), state) && length(x.args) == 5
            mark_binding!(x.args[3], x)
        elseif _points_to_Base_macro(x.args[1], Symbol("@enum"), state)
            for i = 3:length(x.args)
                if bindingof(x.args[i]) !== nothing
                    break
                end
                if i == 4 && headof(x.args[4]) === :block
                    for j in 1:length(x.args[4].args)
                        mark_binding!(x.args[4].args[j], x)
                    end
                    break
                end
                mark_binding!(x.args[i], x)
            end
        elseif _points_to_Base_macro(x.args[1], Symbol("@goto"), state)
            if length(x.args) == 3 && isidentifier(x.args[3])
                setref!(x.args[3], Binding(noname, nothing, nothing, EXPR[]))
            end
        elseif _points_to_Base_macro(x.args[1], Symbol("@label"), state)
            if length(x.args) == 3 && isidentifier(x.args[3])
                mark_binding!(x.args[3])
            end
        elseif _points_to_Base_macro(x.args[1], Symbol("@NamedTuple"), state) && length(x.args) > 2 && headof(x.args[3]) == :braces
            for a in x.args[3].args
                if CSTParser.isdeclaration(a) && isidentifier(a.args[1]) && !hasref(a.args[1])
                    setref!(a.args[1], Binding(noname, nothing, nothing, EXPR[]))
                end
            end
        elseif is_nospecialize(x.args[1])
            for i = 2:length(x.args)
                if bindingof(x.args[i]) !== nothing
                    break
                end
                mark_binding!(x.args[i], x)
            end
        # elseif _points_to_arbitrary_macro(x.args[1], :Turing, :model, state) && length(x) == 3 &&
        #     isassignment(x.args[3]) &&
        #     headof(x.args[3].args[2]) === CSTParser.Begin && length(x.args[3].args[2]) == 3 && headof(x.args[3].args[2].args[2]) === :block
        #     for i = 1:length(x.args[3].args[2].args[2])
        #         ex = x.args[3].args[2].args[2].args[i]
        #         if isbinarycall(ex, "~")
        #             mark_binding!(ex)
        #         end
        #     end
        # elseif _points_to_arbitrary_macro(x.args[1], :JuMP, :variable, state)
        #     if length(x.args) < 3
        #         return
        #     elseif length(x) >= 5 && ispunctuation(x[2])
        #         _mark_JuMP_binding(x[5])
        #     else
        #         _mark_JuMP_binding(x[3])
        #     end
        # elseif (_points_to_arbitrary_macro(x[1], :JuMP, :expression, state) ||
        #     _points_to_arbitrary_macro(x[1], :JuMP, :NLexpression, state) ||
        #     _points_to_arbitrary_macro(x[1], :JuMP, :constraint, state) || _points_to_arbitrary_macro(x[1], :JuMP, :NLconstraint, state)) && length(x) > 1
        #     if ispunctuation(x[2])
        #         if length(x) == 8
        #             _mark_JuMP_binding(x[5])
        #         end
        #     else
        #         if length(x) == 4
        #             _mark_JuMP_binding(x[3])
        #         end
        #     end
        end
    end
end

function _rem_ref(x::EXPR)
    if headof(x) === :ref && length(x.args) > 0
        return x.args[1]
    end
    return x
end

is_nospecialize(x) = isidentifier(x) && valofid(x) == "@nospecialize"

function _mark_JuMP_binding(arg)
    if isidentifier(arg) || headof(arg) === :ref
        mark_binding!(_rem_ref(arg))
    elseif isbinarycall(arg, "==") || isbinarycall(arg, "<=")  || isbinarycall(arg, ">=")
        if isidentifier(arg.args[1]) || headof(arg.args[1]) === :ref
            mark_binding!(_rem_ref(arg.args[1]))
        else
            mark_binding!(_rem_ref(arg.args[3]))
        end
    elseif headof(arg) === :comparision && length(arg.args) == 5
        mark_binding!(_rem_ref(arg.args[3]))
    end
end

function _points_to_Base_macro(x::EXPR, name, state)
    CSTParser.is_getfield_w_quotenode(x) && return _points_to_Base_macro(x.args[2].args[1], name, state)
    haskey(getsymbols(state)[:Base], name) || return false
    targetmacro =  maybe_lookup(getsymbols(state)[:Base][name], state)
    isidentifier(x) && Symbol(valofid(x)) == name && (ref = refof(x)) !== nothing &&
    (ref == targetmacro || (ref isa Binding && ref.val == targetmacro))
end

function _points_to_arbitrary_macro(x::EXPR, module_name, name, state)
    length(x.args) == 2 && isidentifier(x.args[2]) && valof(x.args[2]) == name && haskey(getsymbols(state), Symbol(module_name)) && haskey(getsymbols(state)[Symbol(module_name)], Symbol("@", name)) && (refof(x.args[2]) == maybe_lookup(getsymbols(state)[Symbol(module_name)][Symbol("@", name)], state) ||
    (refof(x.args[2]) isa Binding && refof(x.args[2]).val == maybe_lookup(getsymbols(state)[Symbol(module_name)][Symbol("@", name)], state)))
end

maybe_lookup(x, env::ExternalEnv) = x isa SymbolServer.VarRef ? SymbolServer._lookup(x, getsymbols(env), true) : x
maybe_lookup(x, state::State) = maybe_lookup(x, state.env)

function maybe_eventually_get_id(x::EXPR)
    if isidentifier(x)
        return x
    elseif isbracketed(x)
        return maybe_eventually_get_id(x.args[1])
    end
    return nothing
end

is_eventually_interpolated(x::EXPR) = isbracketed(x) ? is_eventually_interpolated(x.args[1]) : isunarysyntax(x) && valof(headof(x)) == "\$"
isquoted(x::EXPR) = headof(x) === :quotenode && hastrivia(x) && isoperator(x.trivia[1]) && valof(x.trivia[1]) == ":"
maybeget_quotedsymbol(x::EXPR) = isquoted(x) ? maybe_eventually_get_id(x.args[1]) : nothing

function is_loop_iterator(x::EXPR)
    CSTParser.is_range(x) &&
    ((parentof(x) isa EXPR && headof(parentof(x)) === :for) ||
    (parentof(x) isa EXPR && parentof(parentof(x)) isa EXPR && headof(parentof(parentof(x))) === :for))
end

"""
    maybe_quoted_list(x::EXPR)

Try and get a list of quoted symbols from x. Return nothing if not possible.
"""
function maybe_quoted_list(x::EXPR)
    names = EXPR[]
    if headof(x) === :vect || headof(x) === :tuple
        for i = 1:length(x.args)
            name = maybeget_quotedsymbol(x.args[i])
            if name !== nothing
                push!(names, name)
            else
                return nothing
            end
        end
        return names
    end
end

"""
interpret_eval(x::EXPR, state)

Naive attempt to interpret `x` as though it has been eval'ed. Lifts
any bindings made within the scope of `x` to the toplevel and replaces
(some) interpolated binding names with the value where possible.
"""
function interpret_eval(x::EXPR, state)
    # make sure we have bindings etc
    state(x)
    tls = retrieve_toplevel_scope(x)
    for ex in collect_expr_with_bindings(x)
        b = bindingof(ex)
        if isidentifier(b.name)
            # The name of the binding is fixed
            add_binding(ex, state, tls)
        elseif isunarysyntax(b.name) && valof(headof(b.name)) == "\$"
            # The name of the binding is variable, we need to work out what the
            # interpolated symbol points to.
            variable_name = b.name.args[1]
            resolve_ref(variable_name, state.scope, state)
            if (ref = refof(variable_name)) isa Binding
                if isassignment(ref.val) && (rhs = maybeget_quotedsymbol(ref.val.args[2])) !== nothing
                    # `name = :something`
                    toplevel_binding = Binding(rhs, b.val, nothing, [])
                    settype!(toplevel_binding, b.type)
                    infer_type(toplevel_binding, tls, state)
                    if scopehasbinding(tls, valofid(toplevel_binding.name))
                        tls.names[valofid(toplevel_binding.name)] = toplevel_binding # TODO: do we need to check whether this adds a method?
                    else
                        tls.names[valofid(toplevel_binding.name)] = toplevel_binding
                    end
                elseif is_loop_iterator(ref.val) && (names = maybe_quoted_list(rhs_of_iterator(ref.val))) !== nothing
                    # name is of a collection of quoted symbols
                    for name in names
                        toplevel_binding = Binding(name, b.val, nothing, [])
                        settype!(toplevel_binding, b.type)
                        infer_type(toplevel_binding, tls, state)
                        if scopehasbinding(tls, valofid(toplevel_binding.name))
                            tls.names[valofid(toplevel_binding.name)] = toplevel_binding # TODO: do we need to check whether this adds a method?
                        else
                            tls.names[valofid(toplevel_binding.name)] = toplevel_binding
                        end
                    end
                end
            end
        end
    end
end


function rhs_of_iterator(x::EXPR)
    if isassignment(x)
        x.args[2]
    else
        x.args[3]
    end
end

function collect_expr_with_bindings(x, bound_exprs=EXPR[])
    if hasbinding(x)
        push!(bound_exprs, x)
        # Assuming here that if an expression has a binding we don't want anything bound to chlid nodes.
    elseif x.args !== nothing && !((CSTParser.defines_function(x) && !is_eventually_interpolated(x.args[1])) || CSTParser.defines_macro(x) || headof(x) === :export)
        for a in x.args
            collect_expr_with_bindings(a, bound_exprs)
        end
    end
    return bound_exprs
end
