# Note: some of CodeTracking's functionality can only be tested by Revise

using CodeTracking
using Test, InteractiveUtils, REPL, LinearAlgebra, SparseArrays
# Note: ColorTypes needs to be installed, but note the intentional absence of `using ColorTypes`

using CodeTracking: line_is_decl

if !isempty(ARGS) && "revise" ∈ ARGS
    # For running tests with and without Revise
    using Revise
end

isdefined(Main, :Revise) ? Main.Revise.includet("script.jl") : include("script.jl")

@testset "CodeTracking.jl" begin
    m = first(methods(f1))
    file, line = whereis(m)
    scriptpath = normpath(joinpath(@__DIR__, "script.jl"))
    @test file == scriptpath
    @test line == (line_is_decl ? 2 : 4)
    trace = try
        call_throws()
    catch
        stacktrace(catch_backtrace())
    end
    @test whereis(trace[2]) == (scriptpath, 9)

    src, line = definition(String, m)
    @test src == chomp("""
    function f1(x, y)
        # A comment
        return x + y
    end
    """)
    @test line == 2
    @test code_string(f1, Tuple{Any,Any}) == src
    @test @code_string(f1(1, 2)) == src

    m = first(methods(f2))
    src, line = definition(String, m)
    @test src == "f2(x, y) = x + y"
    @test line == 14

    m = first(methods(throws))
    src, line = definition(String, m)
    @test startswith(src, "@noinline")
    @test line == 7

    m = first(methods(multilinesig))
    src, line = definition(String, m)
    @test startswith(src, "@inline")
    @test line == 16
    @test @code_string(multilinesig(1, "hi")) == src
    @test_throws ErrorException("no unique matching method found for the specified argument types") @code_string(multilinesig(1, 2))

    m = first(methods(f50))
    src, line = definition(String, m)
    @test occursin("100x", src)
    @test line == 22

    # Issue #81
    m = which(hasrettype, (Int,))
    src, line = definition(String, m)
    @test occursin("Float32", src)
    @test line == 43

    info = CodeTracking.PkgFiles(Base.PkgId(CodeTracking))
    @test Base.PkgId(info) === info.id
    @test CodeTracking.basedir(info) == dirname(@__DIR__)

    io = IOBuffer()
    show(io, info)
    str = String(take!(io))
    @test startswith(str, "PkgFiles(CodeTracking [da1fd8a2-8d9e-5ec2-8556-3022fb5608a2]):\n  basedir:")
    ioctx = IOContext(io, :compact=>true)
    show(ioctx, info)
    str = String(take!(io))
    @test match(r"PkgFiles\(CodeTracking, .*CodeTracking(\.jl)?, Any\[\]\)", str) !== nothing

    @test pkgfiles("ColorTypes") === nothing
    @test_throws ErrorException pkgfiles("NotAPkg")

    # Test a method marked as missing
    m = @which sum(1:5)
    CodeTracking.method_info[m.sig] = missing
    @test whereis(m) == (CodeTracking.maybe_fix_path(String(m.file)), m.line)
    @test definition(m) === nothing

    # Test that definitions at the REPL work with `whereis`
    ex = Base.parse_input_line("replfunc(x) = 1"; filename="REPL[1]")
    eval(ex)
    m = first(methods(replfunc))
    @test whereis(m) == ("REPL[1]", 1)
    # Test with broken lookup
    oldlookup = CodeTracking.method_lookup_callback[]
    CodeTracking.method_lookup_callback[] = m -> error("oops")
    @test whereis(m) == ("REPL[1]", 1)
    CodeTracking.method_lookup_callback[] = oldlookup

    m = first(methods(Test.eval))
    @test occursin(Sys.STDLIB, whereis(m)[1])

    # https://github.com/JuliaDebug/JuliaInterpreter.jl/issues/150
    function f150()
        x = 1 + 1
        @info "hello"
    end
    m = first(methods(f150))
    src = Base.uncompressed_ast(m)
    idx = findfirst(lin -> String(lin.file) == @__FILE__, src.linetable)
    lin = src.linetable[idx]
    file, line = whereis(lin, m)
    @test endswith(file, String(lin.file))
    idx = findfirst(lin -> String(lin.file) != @__FILE__, src.linetable)
    lin = src.linetable[idx]
    file, line = whereis(lin, m)
    @test endswith(file, String(lin.file))

    # Issues raised in #48
    m = @which(sum([1]; dims=1))
    if !isdefined(Main, :Revise)
        def = definition(String, m)
        @test def === nothing || isa(def[1], AbstractString)
        def = definition(Expr, m)
        @test def === nothing || isa(def, Expr)
    else
        def = definition(String, m)
        @test isa(def[1], AbstractString)
        def = definition(Expr, m)
        @test isa(def, Expr)
    end

    # Issue #64
    B = Hermitian(hcat([one(BigFloat) + im]))
    m = @which cholesky(B)
    @test startswith(definition(String, m)[1], "cholesky")

    # Ensure that we don't error on difficult cases
    m = which(+, (AbstractSparseVector, AbstractSparseVector))  # defined inside an `@eval`
    d = definition(String, m)
    @test d === nothing || isa(d[1], AbstractString)

    # Check for existence of file
    id = Base.PkgId("__PackagePrecompilationStatementModule")   # not all Julia versions have this
    mod = try Base.root_module(id) catch nothing end
    if isa(mod, Module)
        m = first(methods(getfield(mod, :eval)))
        @test definition(String, m) === nothing
    end

    # Related to issue [#51](https://github.com/timholy/CodeTracking.jl/issues/51)
    # and https://github.com/JuliaDocs/Documenter.jl/issues/1779
    ex = :(f_no_linenum(::Int) = 1)
    deleteat!(ex.args[2].args, 1)    # delete the file & line number info
    eval(ex)
    @test code_string(f_no_linenum, (Int,)) === nothing
end

@testset "With Revise" begin
    if isdefined(Main, :Revise)
        m = @which gcd(10, 20)
        sigs = signatures_at(Base.find_source_file(String(m.file)), m.line)
        @test !isempty(sigs)
        ex = @code_expr(gcd(10, 20))
        @test ex isa Expr
        body = ex.args[2]
        idx = findfirst(x -> isa(x, LineNumberNode), body.args)
        @test occursin(String(m.file), String(body.args[idx].file))
        @test ex == code_expr(gcd, Tuple{Int,Int})

        m = first(methods(edit))
        sigs = signatures_at(String(m.file), m.line)
        @test !isempty(sigs)
        sigs = signatures_at(Base.find_source_file(String(m.file)), m.line)
        @test !isempty(sigs)

        # issue #23
        @test !isempty(signatures_at("script.jl", 9))

        @test_throws ArgumentError signatures_at("nofile.jl", 1)

        if isdefined(Revise, :add_revise_deps)
            Revise.add_revise_deps()
            sigs = signatures_at(CodeTracking, "src/utils.jl", 5)
            @test length(sigs) == 1       # only isn't available on julia 1.0
            @test first(sigs) == Tuple{typeof(CodeTracking.checkname), Expr, Any}
            @test pkgfiles(CodeTracking).id == Base.PkgId(CodeTracking)
        end

        # REPL (test copied from Revise)
        if isdefined(Base, :active_repl)
            hp = Base.active_repl.interface.modes[1].hist
            fstr = "__fREPL__(x::Int16) = 0"
            histidx = length(hp.history) + 1 - hp.start_idx
            ex = Base.parse_input_line(fstr; filename="REPL[$histidx]")
            f = Core.eval(Main, ex)
            if ex.head === :toplevel
                ex = ex.args[end]
            end
            push!(hp.history, fstr)
            m = first(methods(f))
            @test definition(String, first(methods(f))) == (fstr, 1)
            @test !isempty(signatures_at(String(m.file), m.line))
            pop!(hp.history)
        elseif haskey(ENV, "CI")
            error("CI Revise tests must be run with -i")
        end
    end
end

(a_34)(x::T, y::T) where {T<:Integer} = no_op_err("&", T)
(b_34)(x::T, y::T) where {T<:Integer} = no_op_err("|", T)
c_34(x::T, y::T) where {T<:Integer} = no_op_err("xor", T)

(d_34)(x::T, y::T) where {T<:Number} = x === y
(e_34)(x::T, y::T) where {T<:Real} = no_op_err("<" , T)
(f_34)(x::T, y::T) where {T<:Real} = no_op_err("<=", T)
l = @__LINE__
@testset "#34 last character" begin
    def, line = definition(String, @which d_34(1, 2))
    @test line == l - 3
    @test def == "(d_34)(x::T, y::T) where {T<:Number} = x === y"
end

function g()
    Base.@_inline_meta
    print("hello")
end
@testset "inline macros" begin
    def, line = CodeTracking.definition(String, @which g())
    @test def == """
    function g()
        Base.@_inline_meta
        print("hello")
    end"""
end

@testset "kwargs methods" begin
    m = nothing
    for i in 1:30
        s = Symbol("#func_2nd_kwarg#$i")
        if isdefined(Main, s)
            m = @eval $s
        end
    end
    m === nothing && error("couldn't find keyword function")
    body, loc = CodeTracking.definition(String, first(methods(m)))
    @test loc == 28
    @test body == "func_2nd_kwarg(; kw=2) = true"
end

@testset "method extensions" begin
    body, _ = CodeTracking.definition(String, @which Foo.Bar.fit(1))
    @test body == """
    function Foo.Bar.fit(m)
        return m
    end"""
    body, _ = CodeTracking.definition(String, @which Foo.Bar.fit(1, 2))
    @test body == "Foo.Bar.fit(a, b) = a + b"
end

struct CallOverload
    z
end
(f::CallOverload)(arg) = f.z + arg
@testset "call syntax" begin
    body, _ = CodeTracking.definition(String, @which CallOverload(1)(1))
    @test body == "(f::CallOverload)(arg) = f.z + arg"
end

if VERSION >= v"1.6.0"
@testset "kwfuncs" begin
    body, _ = CodeTracking.definition(String, @which fkw(; x=1))
    @test body == """
    function fkw(; x=1)
        x
    end"""
end
end
