@testset "type inference by use" begin  
cst = parse_and_pass("""
struct T 
end

struct S 
end

f(x::T) = 1
g(x::S) = 1

function ex1(x)
    f(x)
end

function ex2(x)
    f(x)
    g(x)
end

function ex3(x)
    if 1
        f(x)
    else
        f(x)
    end
end

function ex4(x)
    x
    if 1
        f(x)
    end
end

function ex5(x)
    if 1
        f(x)
    else
        g(x)
    end
end

function ex6(x)
    if 1
        y = x
        f(y)
    else
        g(x)
    end
end
""");

T = cst.meta.scope.names["T"]
S = cst.meta.scope.names["S"]

@test cst.meta.scope.names["ex1"].val.meta.scope.names["x"].type == T
@test cst.meta.scope.names["ex2"].val.meta.scope.names["x"].type === nothing
@test cst.meta.scope.names["ex3"].val.meta.scope.names["x"].type === nothing
@test cst.meta.scope.names["ex4"].val.meta.scope.names["x"].type === nothing
@test cst.meta.scope.names["ex5"].val.meta.scope.names["x"].type === nothing
@test cst.meta.scope.names["ex6"].val.meta.scope.names["y"].type === T
end


@testset "loop iterator inference" begin
cst = parse_and_pass("""
begin
abstract type T end
X = Int[]
Y = T[]
end

for x in 1 end
for x in "abc" end
for x in 1:10 end
for x in 1.0:10.0 end
for x in Int[1,2,3] end
for x in X end
for y in Y end
""");

@test cst.args[2].meta.scope.names["x"].type === nothing
@test StaticLint.CoreTypes.ischar(cst.args[3].meta.scope.names["x"].type)
@test StaticLint.CoreTypes.isint(cst.args[4].meta.scope.names["x"].type)
@test StaticLint.CoreTypes.isfloat(cst.args[5].meta.scope.names["x"].type)
@test StaticLint.CoreTypes.isint(cst.args[6].meta.scope.names["x"].type)
@test StaticLint.CoreTypes.isint(cst.args[7].meta.scope.names["x"].type)
@test StaticLint.CoreTypes.isint(cst.args[7].meta.scope.names["x"].type)
@test cst.args[8].meta.scope.names["y"].type == cst.meta.scope.names["T"]
end

@testset "Vector{T} infer" begin
cst = parse_and_pass("""
struct T 
    t1
end
struct S
    s1::Vector{T}
end

function f(s::S)
    t = s.s1[1]
    t # This should be inferred as T
end
""")

@test cst[3].meta.scope.names["t"].type == cst.meta.scope.names["T"]
end
