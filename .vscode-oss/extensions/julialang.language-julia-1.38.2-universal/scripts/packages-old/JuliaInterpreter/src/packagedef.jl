using Base.Meta
import Base: +, -, convert, isless
using Core: CodeInfo, SimpleVector, LineInfoNode, GotoNode, Slot,
            GeneratedFunctionStub, MethodInstance, NewvarNode, TypeName

using UUIDs
using Random
# The following are for circumventing #28, memcpy invalid instruction error,
# in Base and stdlib
using Random.DSFMT
using InteractiveUtils

export @interpret, Compiled, Frame, root, leaf, ExprSplitter,
       BreakpointRef, breakpoint, @breakpoint, breakpoints, enable, disable, remove, toggle,
       debug_command, @bp, break_on, break_off, on_breakpoints_updated

module CompiledCalls
# This module is for handling intrinsics that must be compiled (llvmcall) as well as ccalls
end

# "Backport" of https://github.com/JuliaLang/julia/pull/31536
if VERSION < v"1.2.0-DEV.572"
    Base.convert(::Type{Some{T}}, x::Some{T}) where {T} = x
end

const SlotNamesType = VERSION < v"1.2.0-DEV.606" ? Vector{Any} : Vector{Symbol}

@static if VERSION < v"1.3.0-DEV.179"
    const append_any = Base.append_any
else
    append_any(@nospecialize x...) = append!([], Core.svec((x...)...))
end

if isdefined(Base, :mapany)
    const mapany = Base.mapany
else
    mapany(f, itr) = map!(f, Vector{Any}(undef, length(itr)::Int), itr)  # convenient for Expr.args
end

if isdefined(Base, :ntupleany)
    const ntupleany = Base.ntupleany
else
    @noinline function ntupleany(f, n)
        (n >= 0) || throw(ArgumentError(string("tuple length should be ≥ 0, got ", n)))
        (Any[f(i) for i = 1:n]...,)
    end
end

if !isdefined(Base, Symbol("@something"))
    macro something(x...)
        :(something($(map(esc, x)...)))
    end
end

include("types.jl")
include("utils.jl")
include("construct.jl")
include("localmethtable.jl")
include("interpret.jl")
include("builtins.jl")
include("optimize.jl")
include("commands.jl")
include("breakpoints.jl")

function set_compiled_methods()
    ###########
    # Methods #
    ###########
    # Work around #28 by preventing interpretation of all Base methods that have a ccall to memcpy
    push!(compiled_methods, which(vcat, (Vector,)))
    push!(compiled_methods, first(methods(Base._getindex_ra)))
    push!(compiled_methods, first(methods(Base._setindex_ra!)))
    push!(compiled_methods, which(Base.decompose, (BigFloat,)))
    push!(compiled_methods, which(DSFMT.dsfmt_jump, (DSFMT.DSFMT_state, DSFMT.GF2X)))
    @static if Sys.iswindows()
        push!(compiled_methods, which(InteractiveUtils.clipboard, (AbstractString,)))
    end
    # issue #76
    push!(compiled_methods, which(unsafe_store!, (Ptr{Any}, Any, Int)))
    push!(compiled_methods, which(unsafe_store!, (Ptr, Any, Int)))
    # issue #92
    push!(compiled_methods, which(objectid, Tuple{Any}))
    # issue #106 --- anything that uses sigatomic_(begin|end)
    push!(compiled_methods, which(flush, Tuple{IOStream}))
    push!(compiled_methods, which(disable_sigint, Tuple{Function}))
    push!(compiled_methods, which(reenable_sigint, Tuple{Function}))
    # Signal-handling in the `print` dispatch hierarchy
    push!(compiled_methods, which(Base.unsafe_write, Tuple{Base.LibuvStream,Ptr{UInt8},UInt}))
    push!(compiled_methods, which(print, Tuple{IO,Any}))
    push!(compiled_methods, which(print, Tuple{IO,Any,Any}))
    # Libc.GetLastError()
    @static if Sys.iswindows()
        push!(compiled_methods, which(Base.access_env, Tuple{Function,AbstractString}))
        push!(compiled_methods, which(Base._hasenv, Tuple{Vector{UInt16}}))
    end
    # These are currently extremely slow to interpret (https://github.com/JuliaDebug/JuliaInterpreter.jl/issues/193)
    push!(compiled_methods, which(subtypes, Tuple{Module,Type}))
    push!(compiled_methods, which(subtypes, Tuple{Type}))
    push!(compiled_methods, which(match, Tuple{Regex,String,Int,UInt32}))

    # Anything that ccalls jl_typeinf_begin cannot currently be handled
    for finf in (Core.Compiler.typeinf_code, Core.Compiler.typeinf_ext, Core.Compiler.typeinf_type)
        for m in methods(finf)
            push!(compiled_methods, m)
        end
    end

    # Does an atomic operation via llvmcall (this fixes #354)
    if isdefined(Base, :load_state_acquire)
        for m in methods(Base.load_state_acquire)
            push!(compiled_methods, m)
        end
    end

    # This is about performance, not safety (issue #462)
    push!(compiled_methods, which(nameof, (Module,)))
    push!(compiled_methods, which(Base.binding_module, (Module, Symbol)))
    push!(compiled_methods, which(Base.unsafe_pointer_to_objref, (Ptr,)))
    push!(compiled_methods, which(Vector{Int}, (UndefInitializer, Int)))
    push!(compiled_methods, which(fill!, (Vector{Int8}, Int)))

    ###########
    # Modules #
    ###########
    push!(compiled_modules, Base.Threads)
end

function __init__()
    set_compiled_methods()
    COVERAGE[] = Base.JLOptions().code_coverage
    # If we interpret into Core.Compiler, we need to take precautions to avoid needing
    # inference of JuliaInterpreter methods in the middle of a `ccall(:jl_typeinf_begin, ...)`
    # block.
    # for (sym, RT, AT) in ((:jl_typeinf_begin, Cvoid, ()),
    #                       (:jl_typeinf_end, Cvoid, ()),
    #                       (:jl_isa_compileable_sig, Int32, (Any, Any)),
    #                       (:jl_compress_ast, Any, (Any, Any)),
    #                       # (:jl_set_method_inferred, Ref{Core.CodeInstance}, (Any, Any, Any, Any, Int32, UInt, UInt)),
    #                       (:jl_method_instance_add_backedge, Cvoid, (Any, Any)),
    #                       (:jl_method_table_add_backedge, Cvoid, (Any, Any, Any)),
    #                       (:jl_new_code_info_uninit, Ref{CodeInfo}, ()),
    #                       (:jl_uncompress_argnames, Vector{Symbol}, (Any,)),
    #                       (:jl_get_tls_world_age, UInt, ()),
    #                       (:jl_call_in_typeinf_world, Any, (Ptr{Ptr{Cvoid}}, Cint)),
    #                       (:jl_value_ptr, Any, (Ptr{Cvoid},)),
    #                       (:jl_value_ptr, Ptr{Cvoid}, (Any,)))
    #     fname = Symbol(:ccall_, sym)
    #     qsym = QuoteNode(sym)
    #     argnames = [Symbol(:arg_, string(i)) for i = 1:length(AT)]
    #     TAT = Expr(:tuple, [parametric_type_to_expr(t) for t in AT]...)
    #     def = :($fname($(argnames...)) = ccall($qsym, $RT, $TAT, $(argnames...)))
    #     f = Core.eval(Core.Compiler, def)
    #     compiled_calls[(qsym, RT, Core.svec(AT...), Core.Compiler)] = f
    #     precompile(f, AT)
    # end
end

include("precompile.jl")
_precompile_()
