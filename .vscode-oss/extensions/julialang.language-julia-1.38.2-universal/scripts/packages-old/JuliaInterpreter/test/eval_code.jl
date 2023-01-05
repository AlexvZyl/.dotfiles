import JuliaInterpreter.eval_code

# Simple evaling of function argument
function evalfoo1(x,y)
    x+y
end
frame = JuliaInterpreter.enter_call(evalfoo1, 1, 2)
@test eval_code(frame, "x") == 1
@test eval_code(frame, "y") == 2

# Evaling with sparams
evalsparams(x::T) where T = x
frame = JuliaInterpreter.enter_call(evalsparams, 1)
@test eval_code(frame, "x") == 1
eval_code(frame, "x = 3")
@test eval_code(frame, "x") == 3
@test eval_code(frame, "T") == Int
eval_code(frame, "T = Float32")
@test eval_code(frame, "T") == Float32

# Evaling with keywords
evalkw(x; bar=true) = x
frame = JuliaInterpreter.enter_call(evalkw, 2)
frame = JuliaInterpreter.maybe_step_through_wrapper!(frame)
@test eval_code(frame, "x") == 2
@test eval_code(frame, "bar") == true
eval_code(frame, "bar = false")
@test eval_code(frame, "bar") == false

# Evaling with symbols
evalsym() = (x = :foo)
frame = JuliaInterpreter.enter_call(evalsym)
# Step until the local actually end up getting defined
JuliaInterpreter.step_expr!(frame)
JuliaInterpreter.step_expr!(frame)
@test eval_code(frame, "x") == :foo

# Evaling multiple statements (https://github.com/JuliaDebug/Debugger.jl/issues/188)
frame = JuliaInterpreter.enter_call(evalfoo1, 1, 2)
@test eval_code(frame, "x = 1; y = 2") == 2
@test eval_code(frame, "x") == 1
@test eval_code(frame, "y") == 2

# https://github.com/JuliaDebug/Debugger.jl/issues/177
function f()
    x = 1
    f = ()->(x = 2)
    f()
    x
end
frame = JuliaInterpreter.enter_call(f)
JuliaInterpreter.step_expr!(frame)
JuliaInterpreter.step_expr!(frame)
@test eval_code(frame, "x") == 1
eval_code(frame, "x = 3")
@test eval_code(frame, "x") == 3
JuliaInterpreter.finish!(frame)
@test JuliaInterpreter.get_return(frame) == 2

function debugfun(non_accessible_variable)
    garbage = ones(10)
    map(1:10) do i
        1+1
        a = 5
        @bp
        garbage[i] + non_accessible_variable[i]
        non_accessible_variable = 2
    end
end
fr = JuliaInterpreter.enter_call(debugfun, [1,2])
fr, bp = debug_command(fr, :c)
@test eval_code(fr, "non_accessible_variable") == [1,2]
@test eval_code(fr, "garbage") == ones(10)
eval_code(fr, "non_accessible_variable = 5.0")
@test eval_code(fr, "non_accessible_variable") == 5.0

if VERSION >= v"1.4" # for var"" syntax
    # Evaluating SSAValues
    f(x) = x^2
    frame = JuliaInterpreter.enter_call(f, 5)
    JuliaInterpreter.step_expr!(frame)
    JuliaInterpreter.step_expr!(frame)
    # This could change with changes to Julia lowering
    @test eval_code(frame, "var\"%2\"") == Val(2)
    @test eval_code(frame, "var\"@_1\"") == f
end

function fun(;output=:sym)
   x = 5
   y = 3
end
fr = JuliaInterpreter.enter_call(fun)
fr = JuliaInterpreter.maybe_step_through_wrapper!(fr)
JuliaInterpreter.step_expr!(fr)
@test eval_code(fr, "x") == 5
@test eval_code(fr, "output") == :sym
eval_code(fr, "output = :foo")
@test eval_code(fr, "output") == :foo

let f() = GlobalRef(Main, :doesnotexist)
    fr = JuliaInterpreter.enter_call(f)
    JuliaInterpreter.step_expr!(fr)
    @test eval_code(fr, Symbol("%1")) == GlobalRef(Main, :doesnotexist)
end
