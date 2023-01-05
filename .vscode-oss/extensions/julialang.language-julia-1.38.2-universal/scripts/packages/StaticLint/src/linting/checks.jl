@enum(
    LintCodes,

    MissingRef,
    IncorrectCallArgs,
    IncorrectIterSpec,
    NothingEquality,
    NothingNotEq,
    ConstIfCondition,
    EqInIfConditional,
    PointlessOR,
    PointlessAND,
    UnusedBinding,
    InvalidTypeDeclaration,
    UnusedTypeParameter,
    IncludeLoop,
    MissingFile,
    InvalidModuleName,
    TypePiracy,
    UnusedFunctionArgument,
    CannotDeclareConst,
    InvalidRedefofConst,
    NotEqDef,
    KwDefaultMismatch,
    InappropriateUseOfLiteral,
    ShouldBeInALoop,
    TypeDeclOnGlobalVariable,
    UnsupportedConstLocalVariable,
    UnassignedKeywordArgument,
    CannotDefineFuncAlreadyHasValue,
    DuplicateFuncArgName,
    IncludePathContainsNULL,
    IndexFromLength
)

const LintCodeDescriptions = Dict{LintCodes,String}(
    IncorrectCallArgs => "Possible method call error.",
    IncorrectIterSpec => "A loop iterator has been used that will likely error.",
    NothingEquality => "Compare against `nothing` using `===`",
    NothingNotEq => "Compare against `nothing` using `!==`",
    ConstIfCondition => "A boolean literal has been used as the conditional of an if statement - it will either always or never run.",
    EqInIfConditional => "Unbracketed assignment in if conditional statements is not allowed, did you mean to use ==?",
    PointlessOR => "The first argument of a `||` call is a boolean literal.",
    PointlessAND => "The first argument of a `&&` call is a boolean literal.",
    UnusedBinding => "Variable has been assigned but not used.",
    InvalidTypeDeclaration => "A non-DataType has been used in a type declaration statement.",
    UnusedTypeParameter => "A DataType parameter has been specified but not used.",
    IncludeLoop => "Loop detected, this file has already been included.",
    MissingFile => "The included file can not be found.",
    InvalidModuleName => "Module name matches that of its parent.",
    TypePiracy => "An imported function has been extended without using module defined typed arguments.",
    UnusedFunctionArgument => "An argument is included in a function signature but not used within its body.",
    CannotDeclareConst => "Cannot declare constant; it already has a value.",
    InvalidRedefofConst => "Invalid redefinition of constant.",
    NotEqDef => "`!=` is defined as `const != = !(==)` and should not be overloaded. Overload `==` instead.",
    KwDefaultMismatch => "The default value provided does not match the specified argument type.",
    InappropriateUseOfLiteral => "You really shouldn't be using a literal value here.",
    ShouldBeInALoop => "`break` or `continue` used outside loop.",
    TypeDeclOnGlobalVariable => "Type declarations on global variables are not yet supported.",
    UnsupportedConstLocalVariable => "Unsupported `const` declaration on local variable.",
    UnassignedKeywordArgument => "Keyword argument not assigned.",
    CannotDefineFuncAlreadyHasValue => "Cannot define function ; it already has a value.",
    DuplicateFuncArgName => "Function argument name not unique.",
    IncludePathContainsNULL => "Cannot include file, path contains NULL characters.",
    IndexFromLength => "Indexing with indices obtained from `length`, `size` etc is discouraged. Use `eachindex` or `axes` instead."
)

haserror(m::Meta) = m.error !== nothing
haserror(x::EXPR) = hasmeta(x) && haserror(x.meta)
errorof(x::EXPR) = hasmeta(x) ? x.meta.error : nothing
function seterror!(x::EXPR, e)
    if !hasmeta(x)
        x.meta = Meta()
    end
    x.meta.error = e
end

const default_options = (true, true, true, true, true, true, true, true, true, true)

struct LintOptions
    call::Bool
    iter::Bool
    nothingcomp::Bool
    constif::Bool
    lazy::Bool
    datadecl::Bool
    typeparam::Bool
    modname::Bool
    pirates::Bool
    useoffuncargs::Bool
end
LintOptions() = LintOptions(default_options...)
LintOptions(::Colon) = LintOptions(fill(true, length(default_options))...)

LintOptions(options::Vararg{Union{Bool,Nothing},length(default_options)}) =
    LintOptions(something.(options, default_options)...)

function check_all(x::EXPR, opts::LintOptions, env::ExternalEnv)
    # Do checks
    opts.call && check_call(x, env)
    opts.iter && check_loop_iter(x, env)
    opts.nothingcomp && check_nothing_equality(x, env)
    opts.constif && check_if_conds(x)
    opts.lazy && check_lazy(x)
    opts.datadecl && check_datatype_decl(x, env)
    opts.typeparam && check_typeparams(x)
    opts.modname && check_modulename(x)
    opts.pirates && check_for_pirates(x)
    opts.useoffuncargs && check_farg_unused(x)
    check_kw_default(x, env)
    check_use_of_literal(x)
    check_break_continue(x)
    check_const(x)

    if x.args !== nothing
        for i in 1:length(x.args)
            check_all(x.args[i], opts, env)
        end
    end
end


function _typeof(x, state)
    if x isa EXPR
        if headof(x) in (:abstract, :primitive, :struct)
            return CoreTypes.DataType
        elseif CSTParser.defines_module(x)
            return CoreTypes.Module
        elseif CSTParser.defines_function(x)
            return CoreTypes.Function
        end
    elseif x isa SymbolServer.DataTypeStore
        return CoreTypes.DataType
    elseif x isa SymbolServer.FunctionStore
        return CoreTypes.Function
    end
end

# Call
function struct_nargs(x::EXPR)
    # struct defs wrapped in macros are likely to have some arbirtary additional constructors, so lets allow anything
    parentof(x) isa EXPR && CSTParser.ismacrocall(parentof(x)) && return 0, typemax(Int), Symbol[], true
    minargs, maxargs, kws, kwsplat = 0, 0, Symbol[], false
    args = x.args[3]
    length(args.args) == 0 && return 0, typemax(Int), kws, kwsplat
    inner_constructor = findfirst(a -> CSTParser.defines_function(a), args.args)
    if inner_constructor !== nothing
        return func_nargs(args.args[inner_constructor])
    else
        minargs = maxargs = length(args.args)
    end
    return minargs, maxargs, kws, kwsplat
end

function func_nargs(x::EXPR)
    minargs, maxargs, kws, kwsplat = 0, 0, Symbol[], false
    sig = CSTParser.rem_wheres_decls(CSTParser.get_sig(x))

    if sig.args !== nothing
        for i = 2:length(sig.args)
            arg = unwrap_nospecialize(sig.args[i])
            if isparameters(arg)
                for j = 1:length(arg.args)
                    arg1 = arg.args[j]
                    if iskwarg(arg1)
                        push!(kws, Symbol(CSTParser.str_value(CSTParser.get_arg_name(arg1.args[1]))))
                    elseif isidentifier(arg1) || isdeclaration(arg1)
                        push!(kws, Symbol(CSTParser.str_value(CSTParser.get_arg_name(arg1))))
                    elseif issplat(arg1)
                        kwsplat = true
                    end
                end
            elseif iskwarg(arg)
                if issplat(arg.args[1])
                    maxargs = typemax(Int)
                else
                    maxargs !== typemax(Int) && (maxargs += 1)
                end
            elseif issplat(arg) ||
                (isdeclaration(arg) &&
                ((isidentifier(arg.args[2]) && valofid(arg.args[2]) == "Vararg") ||
                (iscurly(arg.args[2]) && isidentifier(arg.args[2].args[1]) && valofid(arg.args[2].args[1]) == "Vararg")))
                maxargs = typemax(Int)
            else
                minargs += 1
                maxargs !== typemax(Int) && (maxargs += 1)
            end
        end
    end

    return minargs, maxargs, kws, kwsplat
end

function func_nargs(m::SymbolServer.MethodStore)
    minargs, maxargs, kws, kwsplat = 0, 0, Symbol[], false

    for arg in m.sig
        if CoreTypes.isva(last(arg))
            maxargs = typemax(Int)
        else
            minargs += 1
            maxargs !== typemax(Int) && (maxargs += 1)
        end
    end
    for kw in m.kws
        if endswith(String(kw), "...")
            kwsplat = true
        else
            push!(kws, kw)
        end
    end
    return minargs, maxargs, kws, kwsplat
end

function call_nargs(x::EXPR)
    minargs, maxargs, kws = 0, 0, Symbol[]
    if length(x.args) > 0
        for i = 2:length(x.args)
            arg = x.args[i]
            if isparameters(arg)
                for j = 1:length(arg.args)
                    arg1 = arg.args[j]
                    if iskwarg(arg1)
                        push!(kws, Symbol(CSTParser.str_value(CSTParser.get_arg_name(arg1.args[1]))))
                    end
                end
            elseif iskwarg(arg)
                push!(kws, Symbol(CSTParser.str_value(CSTParser.get_arg_name(arg.args[1]))))
            elseif issplat(arg)
                maxargs = typemax(Int)
            else
                minargs += 1
                maxargs !== typemax(Int) && (maxargs += 1)
            end
        end
    else
        @info string("call_nargs: ", to_codeobject(x))
    end

    return minargs, maxargs, kws
end

# compare_f_call(m_counts, call_counts) = true # fallback method

function compare_f_call(
        (ref_minargs, ref_maxargs, ref_kws, kwsplat),
        (act_minargs, act_maxargs, act_kws),
    )
    # check matching on positional arguments
    if act_maxargs == typemax(Int)
        act_minargs <= act_maxargs < ref_minargs && return false
    else
        !(ref_minargs <= act_minargs <= act_maxargs <= ref_maxargs) && return false
    end

    # check matching on keyword arguments
    kwsplat && return true # splatted kw in method so accept any kw in call

    # no splatted kw in method sig
    length(act_kws) > length(ref_kws) && return false # call has more kws than method accepts
    !all(kw in ref_kws for kw in act_kws) && return false # call supplies a kw that isn't defined in the method

    return true
end

function is_something_with_methods(x::Binding)
    (CoreTypes.isfunction(x.type) && x.val isa EXPR) ||
    (CoreTypes.isdatatype(x.type) && x.val isa EXPR && CSTParser.defines_struct(x.val)) ||
    (x.val isa SymbolServer.FunctionStore || x.val isa SymbolServer.DataTypeStore)
end
is_something_with_methods(x::T) where T <: Union{SymbolServer.FunctionStore,SymbolServer.DataTypeStore} = true
is_something_with_methods(x) = false

function check_call(x, env::ExternalEnv)
    if iscall(x)
        parentof(x) isa EXPR && headof(parentof(x)) === :do && return # TODO: add number of args specified in do block.
        length(x.args) == 0 && return
        # find the function we're dealing with
        func_ref = refof_call_func(x)
        func_ref === nothing && return

        if is_something_with_methods(func_ref) && !(func_ref isa Binding && func_ref.val isa EXPR && func_ref.val.head === :macro)
            # intentionally empty
            if func_ref isa Binding && func_ref.val isa EXPR && isassignment(func_ref.val) && isidentifier(func_ref.val.args[1]) && isidentifier(func_ref.val.args[2])
                # if func_ref is a shadow binding (for these purposes, an assignment that just changes the name of a mehtod), redirect to the rhs of the assignment.
                func_ref = refof(func_ref.val.args[2])
            end
        else
            return
        end
        call_counts = call_nargs(x)
        tls = retrieve_toplevel_scope(x)
        tls === nothing && return @warn "Couldn't get top-level scope." # General check, this means something has gone wrong.
        func_ref === nothing && return
        !sig_match_any(func_ref, x, call_counts, tls, env) && seterror!(x, IncorrectCallArgs)
    end
end

function sig_match_any(func_ref::Union{SymbolServer.FunctionStore,SymbolServer.DataTypeStore}, x, call_counts, tls::Scope, env::ExternalEnv)
    iterate_over_ss_methods(func_ref, tls, env, m -> compare_f_call(func_nargs(m), call_counts))
end

function sig_match_any(func_ref::Binding, x, call_counts, tls::Scope, env::ExternalEnv)
    if func_ref.val isa SymbolServer.FunctionStore || func_ref.val isa SymbolServer.DataTypeStore
        match = sig_match_any(func_ref.val, x, call_counts, tls, env)
        match && return true
    end

    has_at_least_one_method = func_ref.val isa EXPR && defines_function(func_ref.val)
    # handle case where func_ref is typed as Function and yet has no methods

    for r in func_ref.refs
        method = get_method(r)
        method === nothing && continue
        has_at_least_one_method = true
        sig_match_any(method, x, call_counts, tls, env) && return true
    end
    return !has_at_least_one_method
end

function sig_match_any(func::EXPR, x, call_counts, tls::Scope, env::ExternalEnv)
    if CSTParser.defines_function(func)
        m_counts = func_nargs(func)
    elseif CSTParser.defines_struct(func)
        m_counts = struct_nargs(func)
    else
        return true # We shouldn't get here
    end
    if compare_f_call(m_counts, call_counts) || (CSTParser.rem_where_decl(CSTParser.get_sig(func)) == x)
        return true
    end
    return false
end

function get_method(name::EXPR)
    f = maybe_get_parent_fexpr(name, x -> CSTParser.defines_function(x) || CSTParser.defines_struct(x))
    if f !== nothing && CSTParser.get_name(f) == name
        return f
    end
end
function get_method(x::Union{SymbolServer.FunctionStore,SymbolServer.DataTypeStore})
    x
end
get_method(x) = nothing

isdocumented(x::EXPR) = parentof(x) isa EXPR && CSTParser.ismacrocall(parentof(x)) && headof(parentof(x).args[1]) === :globalrefdoc

function check_loop_iter(x::EXPR, env::ExternalEnv)
    if headof(x) === :for
        if length(x.args) > 1
            body = x.args[2]
            if headof(x.args[1]) === :block && x.args[1].args !== nothing
                for arg in x.args[1].args
                    check_incorrect_iter_spec(arg, body, env)
                end
            else
                check_incorrect_iter_spec(x.args[1], body, env)
            end
        end
    elseif headof(x) === :generator
        body = x.args[1]
        for i = 2:length(x.args)
            check_incorrect_iter_spec(x.args[i], body, env)
        end
    end
end

function check_incorrect_iter_spec(x, body, env)
    if x.args !== nothing && CSTParser.is_range(x)
        rng = rhs_of_iterator(x)

        if headof(rng) === :FLOAT || headof(rng) === :INTEGER || (iscall(rng) && refof(rng.args[1]) === getsymbols(env)[:Base][:length])
            seterror!(x, IncorrectIterSpec)
        elseif iscall(rng) && valof(rng.args[1]) == ":" &&
            length(rng.args) === 3 &&
            headof(rng.args[2]) === :INTEGER &&
            iscall(rng.args[3]) &&
            length(rng.args[3].args) > 1 && (
                refof(rng.args[3].args[1]) === getsymbols(env)[:Base][:length] ||
                refof(rng.args[3].args[1]) === getsymbols(env)[:Base][:size]
            )
            if length(x.args) >= 1
                lhs = x.args[1]
                arr = rng.args[3].args[2]
                b = refof(arr)

                # 1:length(arr) indexing is ok for Vector and Array specifically
                if b isa Binding && (CoreTypes.isarray(b.type) || CoreTypes.isvector(b.type))
                    return
                end
                if !all_underscore(valof(lhs))
                    if check_is_used_in_getindex(body, lhs, arr)
                        seterror!(x, IndexFromLength)
                    end
                end
            end
        end
    end
end

function check_is_used_in_getindex(expr, lhs, arr)
    if headof(expr) === :ref && expr.args !== nothing && length(expr.args) > 1
        this_arr = expr.args[1]
        if hasref(this_arr) && hasref(arr) && refof(this_arr) == refof(arr)
            for index_arg in expr.args[2:end]
                if hasref(index_arg) && hasref(lhs) && refof(index_arg) == refof(lhs)
                    seterror!(expr, IndexFromLength)
                    return true
                end
            end
        end
    end
    if expr.args !== nothing
        for arg in expr.args
            check_is_used_in_getindex(arg, lhs, arr) && return true
        end
    end
    return false
end

function check_nothing_equality(x::EXPR, env::ExternalEnv)
    if isbinarycall(x) && length(x.args) == 3
        if valof(x.args[1]) == "==" && (
                (valof(x.args[2]) == "nothing" && refof(x.args[2]) === getsymbols(env)[:Core][:nothing]) ||
                (valof(x.args[3]) == "nothing" && refof(x.args[3]) === getsymbols(env)[:Core][:nothing])
            )
            seterror!(x.args[1], NothingEquality)
        elseif valof(x.args[1]) == "!=" && (
                (valof(x.args[2]) == "nothing" && refof(x.args[2]) === getsymbols(env)[:Core][:nothing]) ||
                (valof(x.args[3]) == "nothing" && refof(x.args[3]) === getsymbols(env)[:Core][:nothing])
            )
            seterror!(x.args[1], NothingNotEq)
        end
    end
end

function _get_top_binding(x::EXPR, name::String)
    if scopeof(x) isa Scope
        return _get_top_binding(scopeof(x), name)
    elseif parentof(x) isa EXPR
        return _get_top_binding(parentof(x), name)
    else
        return nothing
    end
end

function _get_top_binding(s::Scope, name::String)
    if scopehasbinding(s, name)
        return s.names[name]
    elseif parentof(s) isa Scope
        return _get_top_binding(parentof(s), name)
    else
        return nothing
    end
end

function _get_global_scope(s::Scope)
    if !CSTParser.defines_module(s.expr) && parentof(s) isa Scope && parentof(s) != s
        return _get_global_scope(parentof(s))
    else
        return s
    end
end

function check_if_conds(x::EXPR)
    if headof(x) === :if
        cond = x.args[1]
        if headof(cond) === :TRUE || headof(cond) === :FALSE
            seterror!(cond, ConstIfCondition)
        elseif isassignment(cond)
            seterror!(cond, EqInIfConditional)
        end
    end
end

function check_lazy(x::EXPR)
    if isbinarysyntax(x)
        if valof(headof(x)) == "||"
            if headof(x.args[1]) === :TRUE || headof(x.args[1]) === :FALSE
                seterror!(x, PointlessOR)
            end
        elseif valof(headof(x)) == "&&"
            if headof(x.args[1]) === :TRUE || headof(x.args[1]) === :FALSE || headof(x.args[2]) === :TRUE || headof(x.args[2]) === :FALSE
                seterror!(x, PointlessAND)
            end
        end
    end
end

is_never_datatype(b, env::ExternalEnv) = false
is_never_datatype(b::SymbolServer.DataTypeStore, env::ExternalEnv) = false
function is_never_datatype(b::SymbolServer.FunctionStore, env::ExternalEnv)
    !(SymbolServer._lookup(b.extends, getsymbols(env)) isa SymbolServer.DataTypeStore)
end
function is_never_datatype(b::Binding, env::ExternalEnv)
    if b.val isa Binding
        return is_never_datatype(b.val, env)
    elseif b.val isa SymbolServer.FunctionStore
        return is_never_datatype(b.val, env)
    elseif CoreTypes.isdatatype(b.type)
        return false
    elseif b.type !== nothing
        return true
    end
    return false
end

function check_datatype_decl(x::EXPR, env::ExternalEnv)
    # Only call in function signatures?
    if isdeclaration(x) && parentof(x) isa EXPR && iscall(parentof(x))
        if (dt = refof_maybe_getfield(last(x.args))) !== nothing
            if is_never_datatype(dt, env)
                seterror!(x, InvalidTypeDeclaration)
            end
        elseif CSTParser.isliteral(last(x.args))
            seterror!(x, InvalidTypeDeclaration)
        end
    end
end

function check_modulename(x::EXPR)
    if CSTParser.defines_module(x) && # x is a module
        scopeof(x) isa Scope && parentof(scopeof(x)) isa Scope && # it has a scope and a parent scope
        CSTParser.defines_module(parentof(scopeof(x)).expr) && # the parent scope is a module
        valof(CSTParser.get_name(x)) == valof(CSTParser.get_name(parentof(scopeof(x)).expr)) # their names match
        seterror!(CSTParser.get_name(x), InvalidModuleName)
    end
end

# Check whether function arguments are unused
function check_farg_unused(x::EXPR)
    if CSTParser.defines_function(x)
        sig = CSTParser.rem_wheres_decls(CSTParser.get_sig(x))
        if (headof(x) === :function && length(x.args) == 2 && x.args[2] isa EXPR && length(x.args[2].args) == 1 && CSTParser.isliteral(x.args[2].args[1])) ||
            (length(x.args) > 1 && headof(x.args[2]) === :block && length(x.args[2].args) == 1 && CSTParser.isliteral(x.args[2].args[1]))
            return # Allow functions that return constants
        end
        if iscall(sig)
            arg_names = Set{String}()
            for i = 2:length(sig.args)
                arg = sig.args[i]
                if arg.head === :parameters
                    for arg2 in arg.args
                        !check_farg_unused_(arg2, arg_names) && return
                    end
                else
                    !check_farg_unused_(arg, arg_names) && return
                end
            end
        end
    end
end

function check_farg_unused_(arg, arg_names)
    if hasbinding(arg)
    elseif iskwarg(arg) && hasbinding(arg.args[1])
        arg = arg.args[1]
    elseif is_nospecialize_call(arg) && hasbinding(unwrap_nospecialize(arg))
        arg = unwrap_nospecialize(arg)
    else
        return false
    end
    b = bindingof(arg)

    # We don't care about these
    valof(b.name) isa String && all_underscore(valof(b.name)) && return false

    if b === nothing ||
        # no refs:
       isempty(b.refs) ||
        # only self ref:
       (length(b.refs) == 1 && first(b.refs) == b.name) ||
        # first usage has binding:
        (length(b.refs) > 1 && b.refs[2] isa EXPR && hasbinding(b.refs[2]))
        seterror!(arg, UnusedFunctionArgument)
    end

    if valof(b.name) === nothing
    elseif valof(b.name) in arg_names
        seterror!(arg, DuplicateFuncArgName)
    else
        push!(arg_names, valof(b.name))
    end
    true
end

function unwrap_nospecialize(x)
    is_nospecialize_call(x) || return x
    x.args[3]
end

function is_nospecialize_call(x)
    CSTParser.ismacrocall(x) &&
    CSTParser.ismacroname(x.args[1]) &&
    is_nospecialize(x.args[1])
end

"""
collect_hints(x::EXPR, env, missingrefs = :all, isquoted = false, errs = Tuple{Int,EXPR}[], pos = 0)

Collect hints and errors from an expression. `missingrefs` = (:none, :id, :all) determines whether unresolved
identifiers are marked, the :all option will mark identifiers used in getfield calls."
"""
function collect_hints(x::EXPR, env, missingrefs=:all, isquoted=false, errs=Tuple{Int,EXPR}[], pos=0)
    if quoted(x)
        isquoted = true
    elseif isquoted && unquoted(x)
        isquoted = false
    end
    if headof(x) === :errortoken
        # collect parse errors
        push!(errs, (pos, x))
    elseif !isquoted
        if missingrefs != :none && isidentifier(x) && !hasref(x) &&
            !(valof(x) == "var" && parentof(x) isa EXPR && isnonstdid(parentof(x))) &&
            !((valof(x) == "stdcall" || valof(x) == "cdecl" || valof(x) == "fastcall" || valof(x) == "thiscall" || valof(x) == "llvmcall") && is_in_fexpr(x, x -> iscall(x) && isidentifier(x.args[1]) && valof(x.args[1]) == "ccall"))

            push!(errs, (pos, x))
        elseif haserror(x) && errorof(x) isa StaticLint.LintCodes
            # collect lint hints
            push!(errs, (pos, x))
        end
    elseif isquoted && missingrefs == :all && should_mark_missing_getfield_ref(x, env)
        push!(errs, (pos, x))
    end

    for i in 1:length(x)
        collect_hints(x[i], env, missingrefs, isquoted, errs, pos)
        pos += x[i].fullspan
    end

    errs
end

function refof_maybe_getfield(x::EXPR)
    if isidentifier(x)
        return refof(x)
    elseif is_getfield_w_quotenode(x)
        return refof(x.args[2].args[1])
    end
end

function should_mark_missing_getfield_ref(x, env)
    if isidentifier(x) && !hasref(x) && # x has no ref
    parentof(x) isa EXPR && headof(parentof(x)) === :quotenode && parentof(parentof(x)) isa EXPR && is_getfield(parentof(parentof(x)))  # x is the rhs of a getproperty
        lhsref = refof_maybe_getfield(parentof(parentof(x)).args[1])
        hasref(x) && return false # We've resolved
        if lhsref isa SymbolServer.ModuleStore || (lhsref isa Binding && lhsref.val isa SymbolServer.ModuleStore)
            # a module, we should know this.
            return true
        elseif lhsref isa Binding
            # by-use type inference runs after we've resolved references so we may not have known lhsref's type first time round, lets try and find `x` again
            resolve_getfield(x, lhsref, ResolveOnly(retrieve_scope(x), env, nothing)) # FIXME: Setting `server` to nothing might be sketchy?
            hasref(x) && return false # We've resolved
            if lhsref.val isa Binding
                lhsref = lhsref.val
            end
            lhsref = get_root_method(lhsref, nothing)
            if lhsref isa EXPR
                # Not clear what is happening here.
                return false
            elseif lhsref.type isa SymbolServer.DataTypeStore && !(isempty(lhsref.type.fieldnames) || isunionfaketype(lhsref.type.name) || has_getproperty_method(lhsref.type, env))
                return true
            elseif lhsref.type isa Binding && lhsref.type.val isa EXPR && CSTParser.defines_struct(lhsref.type.val) && !has_getproperty_method(lhsref.type)
                # We may have infered the lhs type after the semantic pass that was resolving references. Copied from `resolve_getfield(x::EXPR, parent_type::EXPR, state::State)::Bool`.
                if scopehasbinding(scopeof(lhsref.type.val), valof(x))
                    setref!(x, scopeof(lhsref.type.val).names[valof(x)])
                    return false
                end
                return true
            end
        end
    end
    return false
end

unwrap_fakeunionall(x) = x isa SymbolServer.FakeUnionAll ? unwrap_fakeunionall(x.body) : x
function has_getproperty_method(b::SymbolServer.DataTypeStore, env)
    getprop_vr = SymbolServer.VarRef(SymbolServer.VarRef(nothing, :Base), :getproperty)
    if haskey(getsymbolextendeds(env), getprop_vr)
        for ext in getsymbolextendeds(env)[getprop_vr]
            for m in SymbolServer._lookup(ext, getsymbols(env))[:getproperty].methods
                t = unwrap_fakeunionall(m.sig[1][2])
                !(t isa SymbolServer.FakeUnion) && t.name == b.name.name && return true
            end
        end
    else
        for m in getsymbols(env)[:Base][:getproperty].methods
            t = unwrap_fakeunionall(m.sig[1][2])
            !(t isa SymbolServer.FakeUnion) && t.name == b.name.name && return true
        end
    end
    return false
end

function has_getproperty_method(b::Binding)
    if b.val isa Binding || b.val isa SymbolServer.DataTypeStore
        return has_getproperty_method(b.val)
    elseif b isa Binding && CoreTypes.isdatatype(b.type)
        for ref in b.refs
            if ref isa EXPR && is_type_of_call_to_getproperty(ref)
                return true
            end
        end
    end
    return false
end

function is_type_of_call_to_getproperty(x::EXPR)
    function is_call_to_getproperty(x::EXPR)
        if iscall(x)
            func_name = x.args[1]
            return (isidentifier(func_name) && valof(func_name) == "getproperty") || # getproperty()
            (is_getfield_w_quotenode(func_name) && isidentifier(func_name.args[2].args[1]) && valof(func_name.args[2].args[1]) == "getproperty") # Base.getproperty()
        end
        return false
    end

    return parentof(x) isa EXPR && parentof(parentof(x)) isa EXPR &&
        ((isdeclaration(parentof(x)) && x === parentof(x).args[2] && is_call_to_getproperty(parentof(parentof(x)))) ||
        (iscurly(parentof(x)) && x === parentof(x).args[1] && isdeclaration(parentof(parentof(x))) &&  parentof(parentof(parentof(x))) isa EXPR && is_call_to_getproperty(parentof(parentof(parentof(x))))))
end

isunionfaketype(t::SymbolServer.FakeTypeName) = t.name.name === :Union && t.name.parent isa SymbolServer.VarRef && t.name.parent.name === :Core

function check_typeparams(x::EXPR)
    if iswhere(x)
        for i in 2:length(x.args)
            a = x.args[i]
            if hasbinding(a) && (bindingof(a).refs === nothing || length(bindingof(a).refs) < 2)
                seterror!(a, UnusedTypeParameter)
            end
        end
    end
end

function check_for_pirates(x::EXPR)
    if CSTParser.defines_function(x)
        sig = CSTParser.rem_where_decl(CSTParser.get_sig(x))
        fname = CSTParser.get_name(sig)
        if fname_is_noteq(fname)
            seterror!(x, NotEqDef)
        elseif iscall(sig) && hasbinding(x) && overwrites_imported_function(refof(fname))
            for i = 2:length(sig.args)
                if hasbinding(sig.args[i]) && bindingof(sig.args[i]).type isa Binding
                    return
                elseif refers_to_nonimported_type(sig.args[i])
                    return
                end
            end
            seterror!(x, TypePiracy)
        end
    end
end

function fname_is_noteq(x)
    if x isa EXPR
        if isoperator(x) && valof(x) == "!="
            return true
        elseif is_getfield_w_quotenode(x)
            return fname_is_noteq(x.args[2].args[1])
        end
    end
    return false
end

function refers_to_nonimported_type(arg::EXPR)
    arg = CSTParser.rem_wheres(arg)
    if hasref(arg) && refof(arg) isa Binding
        return true
    elseif isunarysyntax(arg) && (valof(headof(arg)) == "::" || valof(headof(arg)) == "<:")
        return refers_to_nonimported_type(arg.args[1])
    elseif isdeclaration(arg)
        return refers_to_nonimported_type(arg.args[2])
    elseif iscurly(arg)
        for i = 1:length(arg.args)
            if refers_to_nonimported_type(arg.args[i])
                return true
            end
        end
        return false
    end
    return false
end

overwrites_imported_function(b) = false
function overwrites_imported_function(b::Binding)
    if ((b.val isa SymbolServer.FunctionStore || b.val isa SymbolServer.DataTypeStore) &&
        (is_in_fexpr(b.name, x -> headof(x) === :import)) || (b.refs isa Vector && length(b.refs) > 0 && (first(b.refs) isa SymbolServer.FunctionStore || first(b.refs) isa SymbolServer.DataTypeStore)))
        return true
    end
    return false
end

# Now called from add_binding
# Should return true/false indicating whether the binding should actually be added?
function check_const_decl(name::String, b::Binding, scope)
    # assumes `scopehasbinding(scope, name)`
    b.val isa Binding && return check_const_decl(name, b.val, scope)
    if b.val isa EXPR && (CSTParser.defines_datatype(b.val) || is_const(bind))
        seterror!(b.val, CannotDeclareConst)
    else
        prev = scope.names[name]
        if (CoreTypes.isdatatype(prev.type) && !is_mask_binding_of_datatype(prev)) || is_const(prev)
            if b.val isa EXPR && prev.val isa EXPR && !in_same_if_branch(b.val, prev.val)
                return
            end
            if b.val isa EXPR
                seterror!(b.val, InvalidRedefofConst)
            else
                # TODO check what's going on here
                seterror!(b.name, InvalidRedefofConst)
            end
        end
    end
end

function is_mask_binding_of_datatype(b::Binding)
    b.val isa EXPR && CSTParser.isassignment(b.val) && (rhsref = refof(b.val.args[2])) !== nothing && (rhsref isa SymbolServer.DataTypeStore || (rhsref.val isa EXPR && rhsref.val isa SymbolServer.DataTypeStore) || (rhsref.val isa EXPR && CSTParser.defines_datatype(rhsref.val)))
end

# check whether a and b are in all the same :if blocks and in the same branches
in_same_if_branch(a::EXPR, b::EXPR) = in_same_if_branch(find_if_parents(a), find_if_parents(b))
in_same_if_branch(a::Dict, b::EXPR) = in_same_if_branch(a, find_if_parents(b))
function in_same_if_branch(a::Dict, b::Dict)
    return length(a) == length(b) && all(k in keys(b) for k in keys(a)) && all(a[k] == b[k] for k in keys(a))
end

# find any parent nodes that are :if blocks and a pseudo-index of which branch
# x is in
function find_if_parents(x::EXPR, current=Int[], list=Dict{EXPR,Vector{Int}}())
    if x.head in (:block, :elseif) && parentof(x) isa EXPR && headof(parentof(x)) in (:if, :elseif)
        i = 1
        while i <= length(parentof(x).args)
            if parentof(x).args[i] == x
                pushfirst!(current, i)
                break
            end
            i += 1
        end
        if headof(parentof(x)) == :if
            list[parentof(x)] = current
            current = []
        end
    end
    return parentof(x) isa EXPR ? find_if_parents(parentof(x), current, list) : list
end

is_const(x) = false
is_const(b::Binding) = is_const(b.val)
is_const(x::EXPR) = is_const_expr(parentof(x))

is_const_expr(x) = false
is_const_expr(x::EXPR) = headof(x) === :const


"""
    check_kw_default(x::EXPR, server)

Check that the default value matches the type for keyword arguments. Following types are
checked: `String, Symbol, Int, Char, Bool, Float32, Float64, UInt8, UInt16, UInt32,
UInt64, UInt128`.
"""
function check_kw_default(x::EXPR, env::ExternalEnv)
    if headof(x) == :kw && isdeclaration(x.args[1]) && CSTParser.isliteral(x.args[2]) && hasref(x.args[1].args[2])
        decl_T = refof(x.args[1].args[2])
        rhs = x.args[2]
        rhsval = valof(rhs)
        if decl_T == getsymbols(env)[:Core][:String] && !CSTParser.isstringliteral(rhs)
            seterror!(rhs, KwDefaultMismatch)
        elseif decl_T == getsymbols(env)[:Core][:Symbol] && headof(rhs) !== :IDENTIFIER
            seterror!(rhs, KwDefaultMismatch)
        elseif decl_T == getsymbols(env)[:Core][:Int] && headof(rhs) !== :INTEGER
            seterror!(rhs, KwDefaultMismatch)
        elseif decl_T == getsymbols(env)[:Core][Sys.WORD_SIZE == 64 ? :Int64 : :Int32] && headof(rhs) !== :INTEGER
            seterror!(rhs, KwDefaultMismatch)
        elseif decl_T == getsymbols(env)[:Core][:Bool] && !(headof(rhs) === :TRUE || headof(rhs) === :FALSE)
            seterror!(rhs, KwDefaultMismatch)
        elseif decl_T == getsymbols(env)[:Core][:Char] && headof(rhs) !== :CHAR
            seterror!(rhs, KwDefaultMismatch)
        elseif decl_T == getsymbols(env)[:Core][:Float64] && headof(rhs) !== :FLOAT
            seterror!(rhs, KwDefaultMismatch)
        elseif decl_T == getsymbols(env)[:Core][:Float32] && !(headof(rhs) === :FLOAT && occursin("f", rhsval))
            seterror!(rhs, KwDefaultMismatch)
        else
            for T in (UInt8, UInt16, UInt32, UInt64, UInt128)
                if decl_T == getsymbols(env)[:Core][Symbol(T)]
                    # count the digits without prefix (=0x, 0o, 0b) and make sure it fits
                    # between upper and lower literal boundaries for `T` where the boundaries
                    # depend on the type of literal (binary, octal, hex)
                    n = count(x -> x != '_', rhsval) - 2
                    ub = sizeof(T)
                    lb = ub ÷ 2
                    if headof(rhs) == :BININT
                        8lb < n <= 8ub || seterror!(rhs, KwDefaultMismatch)
                    elseif headof(rhs) == :OCTINT
                        3lb < n <= 3ub || seterror!(rhs, KwDefaultMismatch)
                    elseif headof(rhs) == :HEXINT
                        2lb < n <= 2ub || seterror!(rhs, KwDefaultMismatch)
                    else
                        seterror!(rhs, KwDefaultMismatch)
                    end
                end
            end
            # signed integers of non native size can't be declared as literal
            for T in (Int8, Int16, Sys.WORD_SIZE == 64 ? Int32 : Int64, Int128)
                if decl_T == getsymbols(env)[:Core][Symbol(T)]
                    seterror!(rhs, KwDefaultMismatch)
                end
            end

        end
    end
end

function check_use_of_literal(x::EXPR)
    if CSTParser.defines_module(x) && length(x.args) > 1 && isbadliteral(x.args[2])
        seterror!(x.args[2], InappropriateUseOfLiteral)
    elseif (CSTParser.defines_abstract(x) || CSTParser.defines_primitive(x)) && isbadliteral(x.args[1])
        seterror!(x.args[1], InappropriateUseOfLiteral)
    elseif CSTParser.defines_struct(x) && isbadliteral(x.args[2])
        seterror!(x.args[2], InappropriateUseOfLiteral)
    elseif (isassignment(x) || iskwarg(x)) && isbadliteral(x.args[1])
        seterror!(x.args[1], InappropriateUseOfLiteral)
    elseif isdeclaration(x) && isbadliteral(x.args[2])
        seterror!(x.args[2], InappropriateUseOfLiteral)
    elseif isbinarycall(x, "isa") && isbadliteral(x.args[3])
        seterror!(x.args[3], InappropriateUseOfLiteral)
    end
end

isbadliteral(x::EXPR) = CSTParser.isliteral(x) && (CSTParser.isstringliteral(x) || headof(x) === :INTEGER || headof(x) === :FLOAT || headof(x) === :CHAR || headof(x) === :TRUE || headof(x) === :FALSE)

function check_break_continue(x::EXPR)
    if iskeyword(x) && (headof(x) === :CONTINUE || headof(x) === :BREAK) && !is_in_fexpr(x, x -> headof(x) in (:for, :while))
        seterror!(x, ShouldBeInALoop)
    end
end

function check_const(x::EXPR)
    if headof(x) === :const
        if VERSION < v"1.8.0-DEV.1500" && CSTParser.isassignment(x.args[1]) && CSTParser.isdeclaration(x.args[1].args[1])
            seterror!(x, TypeDeclOnGlobalVariable)
        elseif headof(x.args[1]) === :local
            seterror!(x, UnsupportedConstLocalVariable)
        end
    end
end

function check_unused_binding(b::Binding, scope::Scope)
    if headof(scope.expr) !== :struct && headof(scope.expr) !== :tuple && !all_underscore(valof(b.name))
        refs = loose_refs(b)
        if (isempty(refs) || length(refs) == 1 && refs[1] == b.name) &&
                !is_sig_arg(b.name) && !is_overwritten_in_loop(b.name) &&
                !is_overwritten_subsequently(b, scope) && !is_kw_of_macrocall(b)
            seterror!(b.name, UnusedBinding)
        end
    end
end

all_underscore(s) = false
all_underscore(s::String) = all(==(0x5f), codeunits(s))

function is_sig_arg(x)
    is_in_fexpr(x, CSTParser.iscall)
end

function is_kw_of_macrocall(b::Binding)
    b.val isa EXPR && isassignment(b.val) && parentof(b.val) isa EXPR && CSTParser.ismacrocall(parentof(b.val))
end

function is_overwritten_in_loop(x)
    # Cuts out false positives for check_unused_binding - the linear nature of our
    # semantic passes mean a variable declared at the end of a loop's block but used at
    # the start won't appear to be referenced.

    # Cheap version:
    # is_in_fexpr(x, x -> x.head === :while || x.head === :for)

    # We really want to check whether the enclosing scope(s) of the loop has a binding
    # with matching name.
    # Is this too expensive?
    loop = maybe_get_parent_fexpr(x, x -> x.head === :while || x.head === :for)
    if loop !== nothing
        s = scopeof(loop)
        if s isa Scope && parentof(s) isa Scope
            s2 = check_parent_scopes_for(s, valof(x))
            if s2 isa Scope
                prev_binding = parentof(s2).names[valof(x)]
                if prev_binding isa Binding
                    return true
                    # s = ComesBefore(prev_binding.name, s2.expr, 0)
                    # traverse(parentof(s2).expr, s)
                    # return s.result == 1
                    # for r in prev_binding.refs
                    #     if r isa EXPR && is_in_fexpr(r, x -> x === loop)
                    #         return true
                    #     end
                    # end
                else
                    return false
                end
            end
        else
            return false
        end
    else
        false
    end
    false
end

"""
    ComesBefore

Check whether x1 comes before x2
"""
mutable struct ComesBefore
    x1::EXPR
    x2::EXPR
    result::Int
end

function (state::ComesBefore)(x::EXPR)
    state.result > 0 && return
    if x == state.x1
        state.result = 1
        return
    elseif x == state.x2
        state.result = 2
        return
    end
    if !hasscope(x)
        traverse(x, state)
        state.result > 0 && return
    end
end

"""
    check_parent_scopes_for(s::Scope, name)

Checks whether the parent scope of `s` has the name `name`.
"""
function check_parent_scopes_for(s::Scope, name)
    # This returns `s` rather than the parent so that s.expr can be used in the linear
    # search (e.g. `bound_before`)
    if s.expr.head !== :module && parentof(s) isa Scope && haskey(parentof(s).names, name)
        s
    elseif s.parent isa Scope
        check_parent_scopes_for(parentof(s), name)
    end
end



function is_overwritten_subsequently(b::Binding, scope::Scope)
    valof(b.name) === nothing && return false
    s = BoundAfter(b.name, valof(b.name), 0)
    traverse(scope.expr, s)
    return s.result == 2
end

"""
    ComesBefore

Check whether x1 comes before x2
"""
mutable struct BoundAfter
    x1::EXPR
    name::String
    result::Int
end

function (state::BoundAfter)(x::EXPR)
    state.result > 1 && return
    if x == state.x1
        state.result = 1
        return
    end
    if scopeof(x) isa Scope && haskey(scopeof(x).names, state.name)
        state.result = 2
        return
    end
    traverse(x, state)
end
