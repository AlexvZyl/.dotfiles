struct SLInvalidPath <: Exception
    msg::AbstractString
end

function Base.showerror(io::IO, ex::SLInvalidPath)
    print(io, ex.msg)
end