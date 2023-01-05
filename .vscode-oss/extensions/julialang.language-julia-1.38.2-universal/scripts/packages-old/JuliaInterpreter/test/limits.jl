# This is a test-for-tests, verifying the code in utils.jl.
if !isdefined(@__MODULE__, :read_and_parse)
    include("utils.jl")
end

@testset "Abort" begin
    ex = Base.parse_input_line("""
    x = 1
    for i = 1:10
        x += 1
    end
    let y = 0
        z = 5
    end
    if 2 > 1
        println("Hello, world!")
    end
    @elapsed sum(rand(5))
    """; filename="fake.jl")
    modexs = collect(ExprSplitter(Main, ex))
    # find the 3rd assignment statement in the 2nd frame (corresponding to the x += 1 line)
    frame = Frame(modexs[2]...)
    i = 0
    for k = 1:3
        i = findnext(stmt->isexpr(stmt, :(=)), frame.framecode.src.code, i+1)
    end
    @test Aborted(frame, i).at.line == 3
    # Check interior of let block
    frame = Frame(modexs[3]...)
    i = 0
    for k = 1:2
        i = findnext(stmt->isexpr(stmt, :(=)), frame.framecode.src.code, i+1)
    end
    @test Aborted(frame, i).at.line == 6
    # Check conditional
    frame = Frame(modexs[4]...)
    i = findfirst(stmt->JuliaInterpreter.is_gotoifnot(stmt), frame.framecode.src.code) + 1
    @test Aborted(frame, i).at.line == 9
    # Check macro
    frame = Frame(modexs[5]...)
    if VERSION < v"1.4.0-DEV.475"
        @test Aborted(frame, 1).at.file == Symbol("util.jl")
    else
        @test Aborted(frame, 1).at.file == Symbol("fake.jl")
    end
end

module EvalLimited end

@testset "evaluate_limited" begin
    aborts = Aborted[]
    ex = Base.parse_input_line("""
    s = 0
    for i = 1:5
        global s
        s += 1
    end
    """)
    modexs = collect(ExprSplitter(EvalLimited, ex))
    nstmts = 1000  # enough to ensure it finishes
    for (mod, ex) in modexs
        frame = Frame(mod, ex)
        @test isa(frame, Frame)
        nstmtsleft = nstmts
        while true
            ret, nstmtsleft = evaluate_limited!(frame, nstmtsleft, true)
            isa(ret, Some{Any}) && break
            isa(ret, Aborted) && push!(aborts, ret)
        end
    end
    @test EvalLimited.s == 5
    @test isempty(aborts)

    ex = Base.parse_input_line("""
    s = 0
    for i = 1:50
        global s
        s += 1
    end
    """; filename="fake.jl")
    if length(ex.args) == 2
        # Sadly, parse_input_line doesn't insert line info at toplevel, so do it manually
        insert!(ex.args, 2, LineNumberNode(2, Symbol("fake.jl")))
        insert!(ex.args, 1, LineNumberNode(1, Symbol("fake.jl")))
    end
    modexs = collect(ExprSplitter(EvalLimited, ex))
    nstmts = 100 # enough to ensure it gets into the loop but doesn't finish
    for (mod, ex) in modexs
        frame = Frame(mod, ex)
        @test isa(frame, Frame)
        nstmtsleft = nstmts
        while true
            ret, nstmtsleft = evaluate_limited!(Compiled(), frame, nstmtsleft, true)
            isa(ret, Some{Any}) && break
            isa(ret, Aborted) && (push!(aborts, ret); break)
        end
    end
    @test 8 < EvalLimited.s < 50  # with Compiled(), 9 statements per iteration
    @test length(aborts) == 1
    @test aborts[1].at.line ∈ (2, 3, 4)  # 2 corresponds to lowering of the for loop

    # Now try again with recursive stack
    empty!(aborts)
    modexs = collect(ExprSplitter(EvalLimited, ex))
    for (mod, ex) in modexs
        frame = Frame(mod, ex)
        @test isa(frame, Frame)
        nstmtsleft = nstmts
        while true
            ret, nstmtsleft = evaluate_limited!(frame, nstmtsleft, true)
            isa(ret, Some{Any}) && break
            isa(ret, Aborted) && (push!(aborts, ret); break)
        end
    end
    @test EvalLimited.s < 5
    @test length(aborts) == 1
    lin = aborts[1].at
    if lin.file == Symbol("fake.jl")
        @test lin.line ∈ (2, 3, 4)
    else
        @test lin.file == Symbol("range.jl")  # if it aborts in `iterate`
    end
end
