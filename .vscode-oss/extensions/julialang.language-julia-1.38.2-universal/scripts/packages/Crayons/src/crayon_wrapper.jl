struct CrayonWrapper
    c::Crayon
    v::Vector{Union{CrayonWrapper,String}}
end

function (c::Crayon)(args::Union{CrayonWrapper,AbstractString}...)
    typefix(cw::CrayonWrapper) = cw
    typefix(str) = String(str)

    CrayonWrapper(c, typefix.(collect(args)))
end

Base.show(io::IO, cw::CrayonWrapper) = _show(io, cw, CrayonStack(incremental = true))

_show(io::IO, str::String, stack::CrayonStack) = print(io, str)

function _show(io::IO, cw::CrayonWrapper, stack::CrayonStack)
    print(io, push!(stack, cw.c))
    for obj in cw.v
        _show(io, obj, stack)
    end
    length(stack.crayons) > 1 && print(io, pop!(stack))
    return
end

Base.:*(c::Crayon, cw::CrayonWrapper) = CrayonWrapper(c * cw.c, cw.v)
Base.:*(cw::CrayonWrapper, c::Crayon) = CrayonWrapper(cw.c * c, cw.v)
