function arg_type(arg, ismethod)
    if ismethod
        if hasbinding(arg)
            if bindingof(arg) isa Binding && bindingof(arg).type !== nothing
                type = bindingof(arg).type
                if type isa Binding && type.val isa SymbolServer.DataTypeStore
                    type = type.val
                end
                return type
            end
        end
    else
        if hasref(arg)
            if refof(arg) isa Binding && refof(arg).type !== nothing
                type = refof(arg).type
                if type isa Binding && type.val isa SymbolServer.DataTypeStore
                    type = type.val
                end
                return type
            end
        elseif headof(arg) === :STRING
            return CoreTypes.String
        elseif headof(arg) === :CHAR
            return CoreTypes.Char
        elseif headof(arg) === :FLOAT
            return CoreTypes.Float64
        elseif headof(arg) === :INT
            return CoreTypes.Int
        elseif headof(arg) === :HEXINT
            if length(arg.val) < 5
                return CoreTypes.UInt8
            elseif length(arg.val) < 7
                return CoreTypes.UInt16
            elseif length(arg.val) < 11
                return CoreTypes.UInt32
            else
                return CoreTypes.UInt64
            end
        elseif headof(arg) === :TRUE || headof(arg) === :FALSE
            return CoreTypes.Bool
        elseif isquotedsymbol(arg)
            return SymbolServer.stdlibs[:Core][:Symbol]
        end
    end
    # VarRef(VarRef(nothing, :Core), :Any)
    CoreTypes.Any
end

isquotedsymbol(x) = x isa EXPR && x.head === :quotenode && length(x.args) == 1 && x.args[1].head === :IDENTIFIER && hastrivia(x)

function call_arg_types(call::EXPR, ismethod)
    types, kws = [], []
    call.args === nothing && return types, kws
    if length(call.args) > 1 && headof(call.args[2]) === :parameters
        for i = 1:length(call.args[2].args)
            push!(kws, call.args[2].args[i].args[1])
        end
        for i = 3:length(call.args)
            push!(types, arg_type(call.args[i], ismethod))
        end
    else
        for i = 2:length(call.args)
            push!(types, arg_type(call.args[i], ismethod))
        end
    end
    types, kws
end

function method_arg_types(call::EXPR)
    types, opts, kws = [], [], []
    call.args === nothing && return types, opts, kws
    if length(call.args) > 1 && headof(call.args[2]) === :parameters
        for i = 1:length(call.args[2].args)
            push!(kws, call.args[2].args[i].args[1])
        end
        for i = 3:length(call.args)
            if CSTParser.iskwarg(call.args[i])
                push!(opts, arg_type(call.args[i].args[1], true))
            else
                push!(types, arg_type(call.args[i], true))
            end
        end
    else
        for i = 2:length(call.args)
            if CSTParser.iskwarg(call.args[i])
                push!(opts, arg_type(call.args[i].args[1], true))
            else
                push!(types, arg_type(call.args[i], true))
            end
        end
    end
    types, opts, kws
end

function find_methods(x::EXPR, store)
    possibles = []
    if iscall(x)
        length(x.args) === 0 && return possibles
        func_ref = refof_call_func(x)
        func_ref === nothing && return possibles
        args, kws = call_arg_types(x, false)
        if func_ref isa Binding && func_ref.val isa SymbolServer.FunctionStore ||
            func_ref isa Binding && func_ref.val isa SymbolServer.DataTypeStore
            func_ref = func_ref.val
        end
        if func_ref isa SymbolServer.FunctionStore || func_ref isa SymbolServer.DataTypeStore
            for method in func_ref.methods
                if match_method(args, kws, method, store)
                    push!(possibles, method)
                end
            end
        elseif func_ref isa Binding
            if (CoreTypes.isfunction(func_ref.type) || CoreTypes.isdatatype(func_ref.type)) && func_ref.val isa EXPR
                for method in func_ref.refs
                    method = get_method(method)
                    if method !== nothing
                        if method isa SymbolServer.FunctionStore
                            for method1 in method.methods
                                if match_method(args, kws, method1, store)
                                    push!(possibles, method1)
                                end
                            end
                        elseif match_method(args, kws, method, store)
                            push!(possibles, method)
                        end
                    end
                end
            elseif (method = method_of_callable_datatype(func_ref)) !== nothing
                if match_method(args, kws, method, store)
                    push!(possibles, method)
                end
            end
        end
    end
    possibles
end

function match_method(args::Vector{Any}, kws::Vector{Any}, method::SymbolServer.MethodStore, store)
    !isempty(kws) && isempty(method.kws) && return false
    nmargs = length(method.sig)
    varargval = nothing
    if nmargs > 0 && last(method.sig)[2] isa SymbolServer.FakeTypeofVararg
        if length(args) == nmargs - 1
            nmargs -= 1
            # vararg can be zero length
        elseif length(args) >= nmargs
            # set aside the type param of the Vararg for later use
            varargval = last(method.sig)[2].T
        end
    end
    if length(args) == nmargs
        for i in 1:length(args)
            if varargval !== nothing && i >= nmargs
                !_issubtype(args[i], varargval, store) && !_issubtype(varargval, args[i], store) && return false
            else
                !_issubtype(args[i], method.sig[i][2], store) && !_issubtype(method.sig[i][2], args[i], store) && return false
            end
            
        end
        return true
    end
    return false
end

function match_method(args::Vector{Any}, kws::Vector{Any}, method::EXPR, store)
    margs, mkws = [], []
    vararg = false
    if CSTParser.defines_struct(method)
        for i in 1:length(method.args[3].args)
            arg = method.args[3].args[i]
            if defines_function(arg)
                # Hit an inner constructor so forget about the default one.
                for arg in method.args[3].args
                    if defines_function(arg)
                        !match_method(args, kws, arg, store) && return false
                    end
                end
                return true
            end
            push!(margs, arg_type(arg, true))
        end
    else
        sig = CSTParser.rem_decl(CSTParser.get_sig(method))
        margs, mopts, mkws = method_arg_types(sig)
        # vararg
        if length(sig.args) > 0
            if CSTParser.issplat(last(sig.args))
                vararg = true
            end
        end
    end
    !isempty(kws) && isempty(mkws) && return false

    if length(margs) < length(args)
        for i in 1:min(length(mopts), length(args) - length(margs))
            push!(margs, mopts[i])
        end
        if vararg
            for _ in 1:length(args) - length(margs)
                push!(margs, CoreTypes.Any)
            end
        end
    end

    if length(args) == length(margs) || (vararg && length(args) == length(margs) - 1)
        for i in 1:length(args)
            !_issubtype(args[i], margs[i], store) && !_issubtype(margs[i], args[i], store) && return false
        end
        return true
    end
    return false
end

function refof_call_func(x)
    if isidentifier(first(x.args)) && hasref(first(x.args))
        return refof(first(x.args))
    elseif is_getfield_w_quotenode(x.args[1]) && (rhs = rhs_of_getfield(x.args[1])) !== nothing && hasref(rhs)
        return refof(rhs)
    else
        return
    end
end

function is_sig_of_method(sig::EXPR, method = maybe_get_parent_fexpr(sig, defines_function))
    method !== nothing && sig == CSTParser.get_sig(method)
end

function method_of_callable_datatype(b::Binding)
    if b.type isa Binding && b.type.type === CoreTypes.DataType
        for ref in b.type.refs
            if ref isa EXPR && ref.parent isa EXPR && isdeclaration(ref.parent) && is_in_fexpr(ref.parent, x -> x.parent isa EXPR && x.parent.head === :call && x == x.parent.args[1] && is_in_funcdef(x.parent))
                return get_parent_fexpr(ref, defines_function)
            end
        end
    end
end
