# This line should have no code
f2(x) = 2x
if true
  f3(x) = 3x
end
f4(x) = 4x; f5(x) = 5x
# This line should have no code
@doc """
`f6(x)` multiplies `x` by 6
"""
f6(x) = 6x
# This line should have no code
@doc """
`f7(x)` multiplies `x` by 7
"""
function f7(x)
    7x
end

f8(x) = 8x

# This line should have no code
module TestModule
end

# This line should have no code
baremodule TestBareModule
end
