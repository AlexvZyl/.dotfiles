function settype!(b::Binding, type::Binding)
    push!(type.refs, b)
    b.type = type
end

function settype!(b::Binding, type)
    b.type = type
end

function infer_type(binding::Binding, scope, state)
    if binding isa Binding
        binding.type !== nothing && return
        if binding.val isa EXPR && CSTParser.defines_module(binding.val)
            settype!(binding, CoreTypes.Module)
        elseif binding.val isa EXPR && CSTParser.defines_function(binding.val)
            settype!(binding, CoreTypes.Function)
        elseif binding.val isa EXPR && CSTParser.defines_datatype(binding.val)
            settype!(binding, CoreTypes.DataType)
        elseif binding.val isa EXPR
            if isassignment(binding.val)
                if CSTParser.is_func_call(binding.val.args[1])
                    settype!(binding, CoreTypes.Function)
                else
                    infer_type_assignment_rhs(binding, state, scope)
                end
            elseif binding.val.head isa EXPR && valof(binding.val.head) == "::"
                infer_type_decl(binding, state, scope)
            elseif iswhere(parentof(binding.val))
                settype!(binding, CoreTypes.DataType)
            end
        end
    end
end

function infer_type_assignment_rhs(binding, state, scope)
    rhs = binding.val.args[2]
    if is_loop_iter_assignment(binding.val)
        settype!(binding, infer_eltype(rhs))
    elseif headof(rhs) === :ref && length(rhs.args) > 1
        ref = refof_maybe_getfield(rhs.args[1])
        if ref isa Binding && ref.val isa EXPR
            settype!(binding, infer_eltype(ref.val))
        end
    else
        if CSTParser.is_func_call(rhs)
            callname = CSTParser.get_name(rhs)
            if isidentifier(callname)
                resolve_ref(callname, scope, state)
                if hasref(callname)
                    rb = get_root_method(refof(callname), state.server)
                    if (rb isa Binding && (CoreTypes.isdatatype(rb.type) || rb.val isa SymbolServer.DataTypeStore)) || rb isa SymbolServer.DataTypeStore
                        settype!(binding, rb)
                    end
                end
            end
        elseif headof(rhs) === :INTEGER
            settype!(binding, CoreTypes.Int)
        elseif headof(rhs) === :HEXINT
            if length(rhs.val) < 5
                settype!(binding, CoreTypes.UInt8)
            elseif length(rhs.val) < 7
                settype!(binding, CoreTypes.UInt16)
            elseif length(rhs.val) < 11
                settype!(binding, CoreTypes.UInt32)
            else
                settype!(binding, CoreTypes.UInt64)
            end
        elseif headof(rhs) === :FLOAT
            settype!(binding, CoreTypes.Float64)
        elseif CSTParser.isstringliteral(rhs)
            settype!(binding, CoreTypes.String)
        elseif headof(rhs) === :TRUE || headof(rhs) === :FALSE
            settype!(binding, CoreTypes.Bool)
        elseif isidentifier(rhs) || is_getfield_w_quotenode(rhs)
            refof_rhs = isidentifier(rhs) ? refof(rhs) : refof_maybe_getfield(rhs)
            if refof_rhs isa Binding
                if refof_rhs.val isa SymbolServer.GenericStore && refof_rhs.val.typ isa SymbolServer.FakeTypeName
                    settype!(binding, maybe_lookup(refof_rhs.val.typ.name, state))
                elseif refof_rhs.val isa SymbolServer.FunctionStore
                    settype!(binding, CoreTypes.Function)
                elseif refof_rhs.val isa SymbolServer.DataTypeStore
                    settype!(binding, CoreTypes.DataType)
                else
                    settype!(binding, refof_rhs.type)
                end
            elseif refof_rhs isa SymbolServer.GenericStore && refof_rhs.typ isa SymbolServer.FakeTypeName
                settype!(binding, maybe_lookup(refof_rhs.typ.name, state))
            elseif refof_rhs isa SymbolServer.FunctionStore
                settype!(binding, CoreTypes.Function)
            elseif refof_rhs isa SymbolServer.DataTypeStore
                settype!(binding, CoreTypes.DataType)
            end
        end
    end
end

function infer_type_decl(binding, state, scope)
    t = binding.val.args[2]
    if isidentifier(t)
        resolve_ref(t, scope, state)
    end
    if iscurly(t)
        t = t.args[1]
        resolve_ref(t, scope, state)
    end
    if CSTParser.is_getfield_w_quotenode(t)
        resolve_getfield(t, scope, state)
        t = t.args[2].args[1]
    end
    if refof(t) isa Binding
        rb = get_root_method(refof(t), state.server)
        if rb isa Binding && CoreTypes.isdatatype(rb.type)
            settype!(binding, rb)
        else
            settype!(binding, refof(t))
        end
    elseif refof(t) isa SymbolServer.DataTypeStore
        settype!(binding, refof(t))
    end
end

# Work out what type a bound variable has by functions that are called on it.
function infer_type_by_use(b::Binding, env::ExternalEnv)
    b.type !== nothing && return # b already has a type
    possibletypes = []
    visitedmethods = []
    ifbranch = nothing
    for ref in b.refs
        new_possibles = []
        ref isa EXPR || continue # skip non-EXPR (i.e. used for handling of globals)
        # Some simple handling for :if blocks
        if ifbranch === nothing
            ifbranch = find_if_parents(ref)
        else
            newbranch = find_if_parents(ref)
            if !in_same_if_branch(ifbranch, newbranch)
                return
            end
            ifbranch = newbranch
        end
        check_ref_against_calls(ref, visitedmethods, new_possibles, env)
        if !isempty(new_possibles)
            if isempty(possibletypes)
                possibletypes = new_possibles
            else
                possibletypes = intersect(possibletypes, new_possibles)
            end
            if isempty(possibletypes)
                return
            end
        end
    end
    # Only do something if we're left with a singleton set at the end.
    if length(possibletypes) == 1
        type = first(possibletypes)
        if type isa Binding
            settype!(b, type)
        elseif type isa SymbolServer.DataTypeStore
            settype!(b, type)
        elseif type isa SymbolServer.VarRef
            settype!(b, SymbolServer._lookup(type, getsymbols(env))) # could be nothing
        elseif type isa SymbolServer.FakeTypeName && isempty(type.parameters)
            settype!(b, SymbolServer._lookup(type.name, getsymbols(env))) # could be nothing
        end
    end
end

function check_ref_against_calls(x, visitedmethods, new_possibles, env::ExternalEnv)
    if is_arg_of_resolved_call(x) && !call_is_func_sig(x.parent)
        sig = parentof(x)
        # x is argument of function call (func) and we know what that function is
        if CSTParser.isidentifier(sig.args[1])
            func = refof(sig.args[1])
        else
            func = refof(sig.args[1].args[2].args[1])
        end
        argi = get_arg_position_in_call(sig, x) # what slot does ref sit in?
        tls = retrieve_toplevel_scope(x)
        if func isa Binding
            for method in func.refs
                method = get_method(method)
                method === nothing && continue
                if method isa EXPR
                    if defines_function(method)
                        get_arg_type_at_position(method, argi, new_possibles)
                    # elseif CSTParser.defines_struct(method)
                        # Can we ignore this? Default constructor gives us no type info?
                    end
                else # elseif what?
                    iterate_over_ss_methods(method, tls, env, m -> (get_arg_type_at_position(m, argi, new_possibles);false))
                end
            end
        else
            iterate_over_ss_methods(func, tls, env, m -> (get_arg_type_at_position(m, argi, new_possibles);false))
        end
    end
end

function call_is_func_sig(call::EXPR)
    # assume initially called on a :call
    if call.parent isa EXPR
        if call.parent.head === :function || CSTParser.is_eq(call.parent.head)
            true
        elseif isdeclaration(call.parent) || iswhere(call.parent)
            call_is_func_sig(call.parent)
        else
            false
        end
    else
        false
    end
end

function is_arg_of_resolved_call(x::EXPR)
    parentof(x) isa EXPR && headof(parentof(x)) === :call && # check we're in a call signature
    (caller = parentof(x).args[1]) !== x && # and that x is not the caller
    ((CSTParser.isidentifier(caller) && hasref(caller)) || (is_getfield(caller) && headof(caller.args[2]) === :quotenode && hasref(caller.args[2].args[1])))
end

function get_arg_position_in_call(sig::EXPR, arg)
    for i in 1:length(sig.args)
        sig.args[i] == arg && return i
    end
end

function get_arg_type_at_position(method, argi, types)
    if method isa EXPR
        sig = CSTParser.get_sig(method)
        if sig !== nothing &&
            sig.args !== nothing && argi <= length(sig.args) &&
            hasbinding(sig.args[argi]) &&
            (argb = bindingof(sig.args[argi]); argb isa Binding && argb.type !== nothing) &&
            !(argb.type in types)
            push!(types, argb.type)
            return
        end
    elseif method isa SymbolServer.DataTypeStore || method isa SymbolServer.FunctionStore
        for m in method.methods
            get_arg_type_at_position(m, argi, types)
        end
    end
    return
end

function get_arg_type_at_position(m::SymbolServer.MethodStore, argi, types)
    if length(m.sig) >= argi && m.sig[argi][2] != SymbolServer.VarRef(SymbolServer.VarRef(nothing, :Core), :Any) && !(m.sig[argi][2] in types)
        push!(types, m.sig[argi][2])
    end
end

# Assumes x.head.val == "="
is_loop_iter_assignment(x::EXPR) = x.parent isa EXPR && ((x.parent.head == :for || x.parent.head == :generator) || (x.parent.head == :block && x.parent.parent isa EXPR && (x.parent.parent.head == :for || x.parent.parent.head == :generator)))

function infer_eltype(x::EXPR)
    if isidentifier(x) && hasref(x) # assume is IDENT
        r = refof(x)
        if r isa Binding && r.val isa EXPR
            if isassignment(r.val) && r.val.args[2] != x
                return infer_eltype(r.val.args[2])
            end
        end
    elseif headof(x) === :ref && hasref(x.args[1])
        r = refof(x.args[1])
        if r isa SymbolServer.DataTypeStore ||
            r isa Binding && CoreTypes.isdatatype(r.type)
            r
        end
    elseif headof(x) === :STRING
        return CoreTypes.Char
    elseif headof(x) === :call && length(x.args) > 2 && CSTParser.is_colon(x.args[1])
        if headof(x.args[2]) === :INTEGER && headof(x.args[3]) === :INTEGER
            return CoreTypes.Int
        elseif headof(x.args[2]) === :FLOAT && headof(x.args[3]) === :FLOAT
            return CoreTypes.Float64
        elseif headof(x.args[2]) === :CHAR && headof(x.args[3]) === :CHAR
            return CoreTypes.Char
        end
    elseif hasbinding(x) && isdeclaration(x) && length(x.args) == 2
        return maybe_get_vec_eltype(x.args[2])
    end
end

function maybe_get_vec_eltype(t)
    if iscurly(t)
        lhs_ref = refof_maybe_getfield(t.args[1])
        if lhs_ref isa SymbolServer.DataTypeStore && CoreTypes.isarray(lhs_ref) && length(t.args) > 1
            refof(t.args[2])
        end
    end
end
