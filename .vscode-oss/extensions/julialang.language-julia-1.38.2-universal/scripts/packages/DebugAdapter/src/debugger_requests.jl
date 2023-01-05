# Request handlers

function run_notification(conn, state::DebuggerState, params::NamedTuple{(:program,),Tuple{String}})
    @debug "run_request"

    state.debug_mode = :launch
    filename_to_debug = isabspath(params.program) ? params.program : joinpath(pwd(), params.program)
    put!(state.next_cmd, (cmd = :run, program = filename_to_debug))
end

function debug_notification(conn, state::DebuggerState, params::DebugArguments)
    @debug "debug_request" params = params

    state.debug_mode = :launch

    filename_to_debug = isabspath(params.program) ? params.program : joinpath(pwd(), params.program)

    @debug "We are debugging the file $filename_to_debug."

    put!(state.next_cmd, (cmd=:set_source_path, source_path=filename_to_debug))

    file_content = try
        read(filename_to_debug, String)
    catch err
        # TODO Think about some way to return an error message in the UI
        JSONRPC.send(conn, finished_notification_type, nothing)
        put!(state.next_cmd, (cmd=:stop,))
        return
    end

    ex = Base.parse_input_line(file_content; filename=filename_to_debug)

    # handle a case when lowering fails
    if !is_valid_expression(ex)
        # TODO Think about some way to return an error message in the UI
        JSONRPC.send(conn, finished_notification_type, nothing)
        put!(state.next_cmd, (cmd=:stop,))
        return
    end

    params.compiledModulesOrFunctions !== missing && set_compiled_items_request(conn, state, (compiledModulesOrFunctions=params.compiledModulesOrFunctions,))
    params.compiledMode !== missing && set_compiled_mode_request(conn, state, (compiledMode=params.compiledMode,))

    state.expr_splitter = JuliaInterpreter.ExprSplitter(Main, ex)
    next_frame = get_next_top_level_frame(state)

    if next_frame === nothing
        JSONRPC.send(conn, finished_notification_type, nothing)
        put!(state.next_cmd, (cmd=:stop,))
        return
    end

    state.frame = next_frame

    if params.stopOnEntry
        JSONRPC.send(conn, stopped_notification_type, StoppedEventArguments("entry", missing, 1, missing, missing, missing))
    elseif JuliaInterpreter.shouldbreak(state.frame, state.frame.pc)
        JSONRPC.send(conn, stopped_notification_type, StoppedEventArguments("breakpoint", missing, 1, missing, missing, missing))
    else
        put!(state.next_cmd, (cmd=:continue,))
    end
end

is_valid_expression(x) = true # atom
is_valid_expression(::Nothing) = false # empty
is_valid_expression(ex::Expr) = !Meta.isexpr(ex, (:incomplete, :error))

function exec_notification(conn, state::DebuggerState, params::ExecArguments)
    @debug "exec_request" params = params

    state.debug_mode = :attach

    state.sources[0] = params.code

    @debug "setting source_path" file = params.file
    put!(state.next_cmd, (cmd = :set_source_path, source_path = params.file))

    params.compiledModulesOrFunctions !== missing && set_compiled_items_request(conn, state, (compiledModulesOrFunctions = params.compiledModulesOrFunctions,))
    params.compiledMode !== missing && set_compiled_mode_request(conn, state, (compiledMode = params.compiledMode,))

    ex = Meta.parse(params.code)
    state.expr_splitter = JuliaInterpreter.ExprSplitter(Main, ex) # TODO: line numbers ?
    state.frame = get_next_top_level_frame(state)

    if params.stopOnEntry
        JSONRPC.send(conn, stopped_notification_type, StoppedEventArguments("entry", missing, 1, missing, missing, missing))
    elseif JuliaInterpreter.shouldbreak(state.frame, state.frame.pc)
        JSONRPC.send(conn, stopped_notification_type, StoppedEventArguments("breakpoint", missing, 1, missing, missing, missing))
    else
        put!(state.next_cmd, (cmd = :continue,))
    end
end

function reset_compiled_items()
    @debug "reset_compiled_items"
    # reset compiled modules/methods
    empty!(JuliaInterpreter.compiled_modules)
    empty!(JuliaInterpreter.compiled_methods)
    empty!(JuliaInterpreter.interpreted_methods)
    JuliaInterpreter.set_compiled_methods()
    JuliaInterpreter.clear_caches()
end

function set_compiled_items_request(conn, state::DebuggerState, params)
    @debug "set_compiled_items_request"
    reset_compiled_items()
    state.not_yet_set_compiled_items = set_compiled_functions_modules!(params)
end

function set_compiled_mode_request(conn, state::DebuggerState, params)
    @debug "set_compiled_mode_request"

    if params.compiledMode
        state.compile_mode = JuliaInterpreter.Compiled()
    else
        state.compile_mode = JuliaInterpreter.finish_and_return!
    end
end

function set_compiled_functions_modules!(items::Vector{String})
    @debug "set_compiled_functions_modules!"

    unset = String[]

    @debug "setting as compiled" items = items

    # sort inputs once so that removed items are at the end
    sort!(items, lt = function (a, b)
        am = startswith(a, '-')
        bm = startswith(b, '-')

        return am == bm ? isless(a, b) : bm
    end)

    # user wants these compiled:
    for acc in items
        if acc == "ALL_MODULES_EXCEPT_MAIN"
            for mod in values(Base.loaded_modules)
                if mod != Main
                    @debug "setting $mod and submodules as compiled via ALL_MODULES_EXCEPT_MAIN"
                    push!(JuliaInterpreter.compiled_modules, mod)
                    toggle_mode_for_all_submodules(mod, true, Set([Main]))
                end
            end
            push!(unset, acc)
            continue
        end
        oacc = acc
        is_interpreted = startswith(acc, '-') && length(acc) > 1
        if is_interpreted
            acc = acc[2:end]
        end
        all_submodules = endswith(acc, '.')
        acc = strip(acc, '.')
        obj = get_obj_by_accessor(acc)

        if obj === nothing
            push!(unset, oacc)
            continue
        end

        if is_interpreted
            if obj isa Base.Callable
                try
                    for m in methods(Base.unwrap_unionall(obj))
                        push!(JuliaInterpreter.interpreted_methods, m)
                    end
                catch err
                    @warn "Setting $obj as an interpreted method failed."
                end
            elseif obj isa Module
                delete!(JuliaInterpreter.compiled_modules, obj)
                if all_submodules
                    toggle_mode_for_all_submodules(obj, false)
                end
                # need to push these into unset because of ALL_MODULES_EXCEPT_MAIN
                # being re-applied every time
                push!(unset, oacc)
            end
        else
            if obj isa Base.Callable
                try
                    for m in methods(Base.unwrap_unionall(obj))
                        push!(JuliaInterpreter.compiled_methods, m)
                    end
                catch err
                    @warn "Setting $obj as an interpreted method failed."
                end
            elseif obj isa Module
                push!(JuliaInterpreter.compiled_modules, obj)
                if all_submodules
                    toggle_mode_for_all_submodules(obj, true)
                end
            end
        end
    end

    @debug "remaining items" unset = unset
    return unset
end

function set_compiled_functions_modules!(params)
    if params.compiledModulesOrFunctions isa Vector && length(params.compiledModulesOrFunctions) > 0
        return set_compiled_functions_modules!(params.compiledModulesOrFunctions)
    end
    return []
end

function toggle_mode_for_all_submodules(mod, compiled, seen = Set())
    for name in names(mod; all = true)
        if isdefined(mod, name)
            obj = getfield(mod, name)
            if obj !== mod && obj isa Module && !(obj in seen)
                push!(seen, obj)
                if compiled
                    push!(JuliaInterpreter.compiled_modules, obj)
                else
                    delete!(JuliaInterpreter.compiled_modules, obj)
                end
                toggle_mode_for_all_submodules(obj, compiled, seen)
            end
        end
    end
end

function get_obj_by_accessor(accessor, super = nothing)
    parts = split(accessor, '.')
    @assert length(parts) > 0
    top = popfirst!(parts)
    if super === nothing
        # try getting module from loaded_modules_array first and then from Main:
        loaded_modules = Base.loaded_modules_array()
        ind = findfirst(==(top), string.(loaded_modules))
        if ind !== nothing
            root = loaded_modules[ind]
            if length(parts) > 0
                return get_obj_by_accessor(join(parts, '.'), root)
            end
            return root
        else
            return get_obj_by_accessor(accessor, Main)
        end
    else
        if isdefined(super, Symbol(top))
            this = getfield(super, Symbol(top))
            if length(parts) > 0
                if this isa Module
                    return get_obj_by_accessor(join(parts, '.'), this)
                end
            else
                return this
            end
        end
    end
    return nothing
end

function set_break_points_request(conn, state::DebuggerState, params::SetBreakpointsArguments)
    @debug "setbreakpoints_request"

    file = params.source.path

    # JuliaInterpreter.remove mutates the vector returned by
    # breakpoints(), so we make a copy to not mess up iteration
    for bp in copy(JuliaInterpreter.breakpoints())
        if bp isa JuliaInterpreter.BreakpointFileLocation
            if bp.path == file
                @debug "Removing breakpoint at $(bp.path):$(bp.line)"
                JuliaInterpreter.remove(bp)
            end
        end
    end

    for bp in params.breakpoints
        condition = bp.condition === missing ? nothing : try
            Meta.parse(bp.condition)
        catch err
            @debug "Invalid BP condition: `$(bp.condition)`. Falling back to always breaking." exception = err
            nothing
        end

        @debug "Setting breakpoint at $(file):$(bp.line) (condition $(condition))"
        JuliaInterpreter.breakpoint(file, bp.line, condition)
    end

    SetBreakpointsResponseArguments([Breakpoint(true) for _ in params.breakpoints])
end

function set_exception_break_points_request(conn, state::DebuggerState, params::SetExceptionBreakpointsArguments)
    @debug "setexceptionbreakpoints_request"

    opts = Set(params.filters)

    if "error" in opts
        JuliaInterpreter.break_on(:error)
    else
        JuliaInterpreter.break_off(:error)
    end

    if "throw" in opts
        JuliaInterpreter.break_on(:throw)
    else
        JuliaInterpreter.break_off(:throw)
    end

    return SetExceptionBreakpointsResponseArguments(String[], missing)
end

function set_function_break_points_request(conn, state::DebuggerState, params::SetFunctionBreakpointsArguments)
    @debug "setfunctionbreakpoints_request"

    bps = map(params.breakpoints) do i
        decoded_name = i.name
        decoded_condition = i.condition

        parsed_condition = try
            decoded_condition == "" ? nothing : Meta.parse(decoded_condition)
        catch err
            @debug "invalid condition: `$(decoded_condition)`. falling back to always breaking." exception = err
            nothing
        end

        try
            parsed_name = Meta.parse(decoded_name)

            if parsed_name isa Symbol
                return (mod = Main, name = parsed_name, signature = nothing, condition = parsed_condition)
            elseif parsed_name isa Expr
                if parsed_name.head == :.
                    # TODO Support this case
                    return nothing
                elseif parsed_name.head == :call
                    all_args_are_legit = true
                    if length(parsed_name.args) > 1
                        for arg in parsed_name.args[2:end]
                            if !(arg isa Expr) || arg.head != Symbol("::") || length(arg.args) != 1
                                all_args_are_legit = false
                            end
                        end
                        if all_args_are_legit

                            return (mod = Main, name = parsed_name.args[1], signature = map(j -> j.args[1], parsed_name.args[2:end]), condition = parsed_condition)
                        else
                            return (mod = Main, name = parsed_name.args[1], signature = nothing, condition = parsed_condition)
                        end
                    else
                        return (mod = Main, name = parsed_name.args[1], signature = nothing, condition = parsed_condition)
                    end
                else
                    return nothing
        end
            else
                return nothing
            end
        catch err
            return nothing
        end

        return nothing
    end

    bps = filter(i -> i !== nothing, bps)

    for bp in JuliaInterpreter.breakpoints()
        if bp isa JuliaInterpreter.BreakpointSignature
            JuliaInterpreter.remove(bp)
        end
    end

    state.not_yet_set_function_breakpoints = Set{Any}(bps)

    attempt_to_set_f_breakpoints!(state.not_yet_set_function_breakpoints)

    return SetFunctionBreakpointsResponseArguments([Breakpoint(true) for i = 1:length(bps)])
end

function sfHint(frame, meth_or_mod_name)
    if endswith(meth_or_mod_name, "#kw")
        return "subtle"
    end
    return missing
end

function stack_trace_request(conn, state::DebuggerState, params::StackTraceArguments)
    @debug "getstacktrace_request"

    frames = StackFrame[]
    fr = state.frame

    if fr === nothing
        @debug fr
        return StackTraceResponseArguments(frames, length(frames))
    end

    curr_fr = JuliaInterpreter.leaf(fr)

    id = 1
    while curr_fr !== nothing
        curr_scopeof = JuliaInterpreter.scopeof(curr_fr)
        curr_whereis = JuliaInterpreter.whereis(curr_fr)
        curr_mod = JuliaInterpreter.moduleof(curr_fr)

        file_name = curr_whereis[1]
        lineno = curr_whereis[2]
        meth_or_mod_name = string(Base.nameof(curr_fr))

        # Is this a file from base?
        if !isabspath(file_name)
            file_name = basepath(file_name)
        end

        sf_hint = sfHint(fr, meth_or_mod_name)
        source_hint, source_origin = missing, missing # could try to de-emphasize certain sources in the future

        if isfile(file_name)
            push!(
                frames,
                StackFrame(
                    id,
                    meth_or_mod_name,
                    Source(
                        basename(file_name),
                        file_name,
                        missing,
                        source_hint,
                        source_origin,
                        missing,
                        missing,
                        missing
                    ),
                    lineno,
                    0,
                    missing,
                    missing,
                    missing,
                    missing,
                    sf_hint
                )
            )
        elseif curr_scopeof isa Method
            ret = JuliaInterpreter.CodeTracking.definition(String, curr_fr.framecode.scope)
            if ret !== nothing
                state.sources[state.next_source_id], loc = ret
                push!(
                    frames,
                    StackFrame(
                        id,
                        meth_or_mod_name,
                        Source(
                            file_name,
                            missing,
                            state.next_source_id,
                            source_hint,
                            source_origin,
                            missing,
                            missing,
                            missing
                        ),
                        lineno,
                        0,
                        missing,
                        missing,
                        missing,
                        missing,
                        sf_hint
                    )
                )
                state.next_source_id += 1
            else
                src = curr_fr.framecode.src
                @static if isdefined(JuliaInterpreter, :copy_codeinfo)
                    src = JuliaInterpreter.copy_codeinfo(src)
                else
                    src = copy(src)
                end
                JuliaInterpreter.replace_coretypes!(src; rev = true)
                code = Base.invokelatest(JuliaInterpreter.framecode_lines, src)

                state.sources[state.next_source_id] = join(code, '\n')

                push!(
                    frames,
                    StackFrame(
                        id,
                        meth_or_mod_name,
                        Source(
                            file_name,
                            missing,
                            state.next_source_id,
                            source_hint,
                            source_origin,
                            missing,
                            missing,
                            missing
                        ),
                        lineno,
                        0,
                        missing,
                        missing,
                        missing,
                        missing,
                        sf_hint
                    )
                )
                state.next_source_id += 1
            end
        else
            # For now we are assuming that this can only happen
            # for code that is passed via the @enter or @run macros,
            # and that code we have stored as source with id 0
            push!(
                    frames,
                    StackFrame(
                        id,
                        meth_or_mod_name,
                        Source(
                            "REPL",
                            missing,
                            0,
                            missing,
                            missing,
                            missing,
                            missing,
                            missing
                        ),
                        lineno,
                        0,
                        missing,
                        missing,
                        missing,
                        missing,
                        missing
                    )
                )
        end

        id += 1
        curr_fr = curr_fr.caller
    end

    return StackTraceResponseArguments(frames, length(frames))
end

function scopes_request(conn, state::DebuggerState, params::ScopesArguments)
    @debug "getscope_request"
    empty!(state.varrefs)

    curr_fr = JuliaInterpreter.leaf(state.frame)

    i = 1

    while params.frameId > i
        curr_fr = curr_fr.caller
        i += 1
    end

    curr_scopeof = JuliaInterpreter.scopeof(curr_fr)
    curr_whereis = JuliaInterpreter.whereis(curr_fr)

    file_name = curr_whereis[1]
    code_range = curr_scopeof isa Method ? JuliaInterpreter.compute_corrected_linerange(curr_scopeof) : nothing

    push!(state.varrefs, VariableReference(:scope, curr_fr))
    local_var_ref_id = length(state.varrefs)

    push!(state.varrefs, VariableReference(:scope_globals, curr_fr))
    global_var_ref_id = length(state.varrefs)

    scopes = []

    if isfile(file_name) && code_range !== nothing
        push!(scopes, Scope(name = "Local", variablesReference = local_var_ref_id, expensive = false, source = Source(name = basename(file_name), path = file_name), line = code_range.start, endLine = code_range.stop))
        push!(scopes, Scope(name = "Global", variablesReference = global_var_ref_id, expensive = false, source = Source(name = basename(file_name), path = file_name), line = code_range.start, endLine = code_range.stop))
    else
        push!(scopes, Scope(name = "Local", variablesReference = local_var_ref_id, expensive = false))
        push!(scopes, Scope(name = "Global", variablesReference = global_var_ref_id, expensive = false))
    end

    curr_mod = JuliaInterpreter.moduleof(curr_fr)
    push!(state.varrefs, VariableReference(:module, curr_mod))

    push!(scopes, Scope(name = "Global ($(curr_mod))", variablesReference = length(state.varrefs), expensive = true))

    return ScopesResponseArguments(scopes)
end

function source_request(conn, state::DebuggerState, params::SourceArguments)
    @debug "getsource_request"

    source_id = params.source.sourceReference

    return SourceResponseArguments(state.sources[source_id], missing)
end

function construct_return_msg_for_var(state::DebuggerState, name, value)
    v_type = typeof(value)
    v_value_as_string = try
        Base.invokelatest(sprintlimited, value)
    catch err
        @debug "error showing value" exception=(err, catch_backtrace())
        "Error while showing this value."
    end

    if (isstructtype(v_type) || value isa AbstractArray || value isa AbstractDict) && !(value isa String || value isa Symbol)
        push!(state.varrefs, VariableReference(:var, value))
        new_var_id = length(state.varrefs)

        named_count = if value isa Array || value isa Tuple
            0
        elseif value isa AbstractArray || value isa AbstractDict
            fieldcount(v_type) > 0 ? 1 : 0
            else
            fieldcount(v_type)
        end

        indexed_count = zero(Int64)

        if value isa AbstractArray || value isa AbstractDict || value isa Tuple
            try
                indexed_count = Int64(Base.invokelatest(length, value))
            catch err
            end
        end

        return Variable(
            name = name,
            value = v_value_as_string,
            type = string(v_type),
            variablesReference = new_var_id,
            namedVariables = named_count,
            indexedVariables = indexed_count
        )
    else
        return Variable(name = name, value = v_value_as_string, type = string(v_type), variablesReference = 0)
    end
end

function construct_return_msg_for_var_with_undef_value(state::DebuggerState, name)
    v_type_as_string = ""

    return Variable(name = name, type = v_type_as_string, value = "#undef", variablesReference = 0)
end

function get_keys_with_drop_take(value, skip_count, take_count)
    collect(Iterators.take(Iterators.drop(keys(value), skip_count), take_count))
end

function get_cartesian_with_drop_take(value, skip_count, take_count)
    collect(Iterators.take(Iterators.drop(CartesianIndices(value), skip_count), take_count))
end

function collect_global_refs(frame::JuliaInterpreter.Frame)
    try
        m = JuliaInterpreter.scopeof(frame)
        m isa Method || return []

        func = frame.framedata.locals[1].value
        args = (Base.unwrap_unionall(m.sig).parameters[2:end]...,)

        ci = code_typed(func, args, optimize = false)[1][1]

        return collect_global_refs(ci)
    catch err
        @error err
        []
    end
end

function collect_global_refs(ci::Core.CodeInfo, refs = Set([]))
    for expr in ci.code
        collect_global_refs(expr, refs)
    end
    refs
end

function collect_global_refs(expr::Expr, refs = Set([]))
    args = Meta.isexpr(expr, :call) ? expr.args[2:end] : expr.args
    for arg in args
        collect_global_refs(arg, refs)
    end

    refs
end

collect_global_refs(expr, refs) = nothing
collect_global_refs(expr::GlobalRef, refs) = push!(refs, expr)

function push_module_names!(variables, state, mod)
    for n in names(mod, all = true)
        !isdefined(mod, n) && continue
        Base.isdeprecated(mod, n) && continue

        x = getfield(mod, n)
    x === Main && continue

        s = string(n)
        startswith(s, "#") && continue

        push!(variables, construct_return_msg_for_var(state, s, x))
    end
end

function variables_request(conn, state::DebuggerState, params::VariablesArguments)
    @debug "getvariables_request"

    var_ref_id = params.variablesReference

    filter_type = coalesce(params.filter, "")
    skip_count = coalesce(params.start, 0)
    take_count = coalesce(params.count, typemax(Int))

    var_ref = state.varrefs[var_ref_id]

    variables = Variable[]

    if var_ref.kind == :scope
        curr_fr = var_ref.value

        vars = JuliaInterpreter.locals(curr_fr)

        for v in vars
            # TODO Figure out why #self# is here in the first place
            # For now we don't report it to the client
            if !startswith(string(v.name), "#") && string(v.name) != ""
                push!(variables, construct_return_msg_for_var(state, string(v.name), v.value))
            end
        end

        if JuliaInterpreter.isexpr(JuliaInterpreter.pc_expr(curr_fr), :return)
            ret_val = JuliaInterpreter.get_return(curr_fr)
            push!(variables, construct_return_msg_for_var(state, "Return Value", ret_val))
        end
    elseif var_ref.kind == :scope_globals
        curr_fr = var_ref.value
        globals = collect_global_refs(curr_fr)

        for g in globals
            if isdefined(g.mod, g.name)
                push!(variables, construct_return_msg_for_var(state, string(g.name), getfield(g.mod, g.name)))
            end
        end
    elseif var_ref.kind == :module
        push_module_names!(variables, state, var_ref.value)
    elseif var_ref.kind == :var
        container_type = typeof(var_ref.value)

        if filter_type == "" || filter_type == "named"
            if (var_ref.value isa AbstractArray || var_ref.value isa AbstractDict) && !(var_ref.value isa Array) &&
                fieldcount(container_type) > 0
                push!(state.varrefs, VariableReference(:fields, var_ref.value))
                new_var_id = length(state.varrefs)
                named_count = fieldcount(container_type)

                push!(variables, Variable(
                    "Fields",
                    "",
                    "",
                    missing,
                    missing,
                    new_var_id,
                    named_count,
                    0,
                    missing
                ))
            elseif var_ref.value isa Module
                push_module_names!(variables, state, var_ref.value)
            else
                for i = Iterators.take(Iterators.drop(1:fieldcount(container_type), skip_count), take_count)
                    s = isdefined(var_ref.value, i) ?
                        construct_return_msg_for_var(state, string(fieldname(container_type, i)), getfield(var_ref.value, i)) :
                        construct_return_msg_for_var_with_undef_value(state, string(fieldname(container_type, i)))
                    push!(variables, s)
                end
            end
        end

        if (filter_type == "" || filter_type == "indexed")
            try
                if var_ref.value isa Tuple
                    for i in Iterators.take(Iterators.drop(1:length(var_ref.value), skip_count), take_count)
                        s = construct_return_msg_for_var(state, join(string.(i), ','), var_ref.value[i])
                        push!(variables, s)
                    end
                elseif var_ref.value isa AbstractArray
                    for i in Base.invokelatest(get_cartesian_with_drop_take, var_ref.value, skip_count, take_count)
                        s = ""
                        try
                            val = Base.invokelatest(getindex, var_ref.value, i)
                            s = construct_return_msg_for_var(state, join(string.(i.I), ','), val)
                        catch err
                            s = Variable(name = join(string.(i.I), ','), type = "", value = "#error", variablesReference = 0)
                        end
                        push!(variables, s)
                    end
                elseif var_ref.value isa AbstractDict
                    for i in Base.invokelatest(get_keys_with_drop_take, var_ref.value, skip_count, take_count)
                        key_as_string = try
                            Base.invokelatest(repr, i)
                        catch err
                            "Error while showing this value."
                        end
                        s = ""
                        try
                            val = Base.invokelatest(getindex, var_ref.value, i)
                            s = construct_return_msg_for_var(state, key_as_string, val)
                        catch err
                            s = Variable(
                                join(string.(i.I), ','),
                                "#error",
                                "",
                                missing,
                                missing,
                                0,
                                0,
                                0,
                                missing
                            )
                        end
                        push!(variables, s)
                    end
                end
            catch err
                push!(variables, Variable(
                    "#error",
                    "This type doesn't implement the expected interface",
                    "",
                    missing,
                    missing,
                    0,
                    0,
                    0,
                    missing
                ))
            end
        end
    elseif var_ref.kind == :fields
        container_type = typeof(var_ref.value)

        if filter_type == "" || filter_type == "named"
            for i = Iterators.take(Iterators.drop(1:fieldcount(container_type), skip_count), take_count)
                s = isdefined(var_ref.value, i) ?
                    construct_return_msg_for_var(state, string(fieldname(container_type, i)), getfield(var_ref.value, i)) :
                    construct_return_msg_for_var_with_undef_value(state, string(fieldname(container_type, i)))
                push!(variables, s)
            end
        end

    end

    return VariablesResponseArguments(variables)
end

function set_variable_request(conn, state::DebuggerState, params::SetVariableArguments)
    varref_id = params.variablesReference
    var_name = params.name
    var_value = params.value

    val_parsed = try
        parsed = Meta.parse(var_value)

        if parsed isa Expr && !(parsed.head == :call || parsed.head == :vect || parsed.head == :tuple)
            return JSONRPC.JSONRPCError(-32600, "Only values or function calls are allowed.", nothing)
        end

        parsed
    catch err
        return JSONRPC.JSONRPCError(-32600, string("Something went wrong in the eval: ", sprint(showerror, err)), nothing)
    end

    var_ref = state.varrefs[varref_id]

    if var_ref.kind == :scope
        try
            ret = JuliaInterpreter.eval_code(var_ref.value, "$var_name = $var_value");

            s = construct_return_msg_for_var(state::DebuggerState, "", ret)

            return SetVariableResponseArguments(s.value, s.type, s.variablesReference, s.namedVariables, s.indexedVariables)
        catch err
            return JSONRPC.JSONRPCError(-32600, string("Something went wrong while setting the variable: ", sprint(showerror, err)), nothing)
        end
    elseif var_ref.kind == :var
        if isnumeric(var_name[1])
            try
                new_val = try
                    Core.eval(Main, val_parsed)
                catch err
                    return JSONRPC.JSONRPCError(-32600, string("Expression could not be evaluated: ", sprint(showerror, err)), nothing)
                end

                idx = Core.eval(Main, Meta.parse("($var_name)"))

                setindex!(var_ref.value, new_val, idx...)

                s = construct_return_msg_for_var(state::DebuggerState, "", new_val)

                return SetVariableResponseArguments(s.value, s.type, s.variablesReference, s.namedVariables, s.indexedVariables)
            catch err
                return JSONRPC.JSONRPCError(-32600, "Something went wrong while setting the variable: $err", nothing)
            end
        else
            if Base.isimmutable(var_ref.value)
                return JSONRPC.JSONRPCError(-32600, "Cannot change the fields of an immutable struct.", nothing)
            else
                try
                    new_val = try
                        Core.eval(Main, val_parsed)
                    catch err
                        return JSONRPC.JSONRPCError(-32600, string("Expression could not be evaluated: ", sprint(showerror, err)), nothing)
                    end

                    setfield!(var_ref.value, Symbol(var_name), new_val)

                    s = construct_return_msg_for_var(state::DebuggerState, "", new_val)

                    return SetVariableResponseArguments(s.value, s.type, s.variablesReference, s.namedVariables, s.indexedVariables)
                catch err
                    return JSONRPC.JSONRPCError(-32600, string("Something went wrong while setting the variable: ", sprint(showerror, err)), nothing)
                end
            end
        end
    elseif var_ref.kind == :scope_globals || var_ref.kind == :module
        mod = if var_ref.value isa JuliaInterpreter.Frame
            JuliaInterpreter.moduleof(var_ref.value)
        elseif var_ref.value isa Module
            var_ref.value
        else
            return JSONRPC.JSONRPCError(-32600, "No module attached to this global variable.", nothing)
        end

        if !(mod isa Module)
            return JSONRPC.JSONRPCError(-32600, "Can't determine the module this variable is defined in.", nothing)
        end

        new_val = try
            mod.eval(Meta.parse("$var_name = $var_value"))
        catch err
            return JSONRPC.JSONRPCError(-32600, string("Something went wrong while setting the variable: ", sprint(showerror, err)), nothing)
        end
        s = construct_return_msg_for_var(state::DebuggerState, "", new_val)

        return SetVariableResponseArguments(s.value, s.type, s.variablesReference, s.namedVariables, s.indexedVariables)
    else
        return JSONRPC.JSONRPCError(-32600, "Unknown variable ref type.", nothing)
    end
end

function restart_frame_request(conn, state::DebuggerState, params::RestartFrameArguments)
    frame_id = params.frameId

    curr_fr = JuliaInterpreter.leaf(state.frame)

        i = 1

    while frame_id > i
        curr_fr = curr_fr.caller
        i += 1
    end

    if curr_fr.caller === nothing
        # We are in the top level

        state.frame = get_next_top_level_frame(state)
    else
        curr_fr.pc = 1
        curr_fr.assignment_counter = 1
        curr_fr.callee = nothing

        state.frame = curr_fr
    end

    put!(state.next_cmd, (cmd = :continue,))

    return RestartFrameResponseResponseArguments()
end

function exception_info_request(conn, state::DebuggerState, params::ExceptionInfoArguments)
    exception_id = string(typeof(state.last_exception))
    exception_description = Base.invokelatest(sprint, Base.showerror, state.last_exception)

    exception_stacktrace = try
        Base.invokelatest(sprint, Base.show_backtrace, state.frame)
    catch err
        "Error while printing the backtrace."
    end

    return ExceptionInfoResponseArguments(exception_id, exception_description, "userUnhandled", ExceptionDetails(missing, missing, missing, missing, exception_stacktrace, missing))
end

function evaluate_request(conn, state::DebuggerState, params::EvaluateArguments)
    @debug "evaluate_request"

    curr_fr = state.frame
    curr_i = 1

    while params.frameId > curr_i
        if curr_fr.caller !== nothing
            curr_fr = curr_fr.caller
            curr_i += 1
        else
            break
        end
    end

    try
        ret_val = JuliaInterpreter.eval_code(curr_fr, params.expression)

        return EvaluateResponseArguments(Base.invokelatest(sprintlimited, ret_val), missing, missing, 0, missing, missing, missing)
    catch err
        @debug "error showing value" exception=(err, catch_backtrace())
        return EvaluateResponseArguments(string("Internal Error: ", sprint(showerror, err)), missing, missing, 0, missing, missing, missing)
    end
end

    function continue_request(conn, state::DebuggerState, params::ContinueArguments)
    @debug "continue_request"

    put!(state.next_cmd, (cmd = :continue,))

    return ContinueResponseArguments(true)
end

function next_request(conn, state::DebuggerState, params::NextArguments)
    @debug "next_request"

    put!(state.next_cmd, (cmd = :next,))

    return NextResponseArguments()
end

function setp_in_request(conn, state::DebuggerState, params::StepInArguments)
    @debug "stepin_request"

    put!(state.next_cmd, (cmd = :stepIn, targetId = params.targetId))

    return StepInResponseArguments()
end

function step_in_targets_request(conn, state::DebuggerState, params::StepInTargetsArguments)
    @debug "stepin_targets_request"

    targets = calls_on_line(state)

    return StepInTargetsResponseArguments([
        StepInTarget(pc, string(expr)) for (pc, expr) in targets
    ])
end

function setp_out_request(conn, state::DebuggerState, params::StepOutArguments)
    @debug "stepout_request"

    put!(state.next_cmd, (cmd = :stepOut,))

    return StepOutResponseArguments()
end

function disconnect_request(conn, state::DebuggerState, params::DisconnectArguments)
    @debug "disconnect_request"

    put!(state.next_cmd, (cmd = :stop,))

    return DisconnectResponseArguments()
end

function terminate_request(conn, state::DebuggerState, params::TerminateArguments)
    @debug "terminate_request"

    JSONRPC.send(conn, finished_notification_type, nothing)
    put!(state.next_cmd, (cmd = :stop,))

    return TerminateResponseArguments()
end

function threads_request(conn, state::DebuggerState, params::Nothing)
    return ThreadsResponseArguments([Thread(id = 1, name = "Main Thread")])
end

function breakpointlocations_request(conn, state::DebuggerState, params::BreakpointLocationsArguments)
    return BreakpointLocationsResponseArguments(BreakpointLocation[])
end
