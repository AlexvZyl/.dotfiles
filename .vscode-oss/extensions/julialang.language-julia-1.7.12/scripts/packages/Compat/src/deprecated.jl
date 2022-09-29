import Dates, LinearAlgebra
Base.@deprecate_binding invokelatest Base.invokelatest false
Base.@deprecate_binding MathConstants Base.MathConstants false
Base.@deprecate_binding Fix2 Base.Fix2 false
Base.@deprecate_binding Sys Base.Sys false
Base.@deprecate_binding AbstractDateTime Dates.AbstractDateTime false
Base.@deprecate_binding tr LinearAlgebra.tr false
Base.@deprecate_binding IteratorSize Base.IteratorSize false
Base.@deprecate_binding IteratorEltype Base.IteratorEltype false
Base.@deprecate_binding opnorm LinearAlgebra.opnorm false
Base.@deprecate_binding norm LinearAlgebra.norm false
Base.@deprecate_binding dot LinearAlgebra.dot false
Base.@deprecate_binding (⋅) LinearAlgebra.dot false
Base.@deprecate_binding notnothing Base.notnothing false
Base.@deprecate_binding qr LinearAlgebra.qr false
Base.@deprecate_binding rmul! LinearAlgebra.rmul! false

for stdlib in [:Base64, :Dates, :DelimitedFiles, :Distributed, :InteractiveUtils, :Libdl,
    :LibGit2, :LinearAlgebra, :Markdown, :Mmap, :Pkg, :Printf, :Random, :REPL,
    :Serialization, :SharedArrays, :Sockets, :SparseArrays, :Statistics, :Test, :Unicode,
    :UUIDs]
    @eval begin
        import $stdlib
        Base.@deprecate_binding $stdlib $stdlib false
    end
end

Base.@deprecate_binding macros_have_sourceloc true false
Base.@deprecate enable_debug(x::Bool) x false

module TypeUtils
    Base.@deprecate_binding isabstract isabstracttype
    Base.@deprecate_binding typename Base.typename
    Base.@pure function _parameter_upper_bound(t::UnionAll, idx)
        return Base.rewrap_unionall((Base.unwrap_unionall(t)::DataType).parameters[idx], t)
    end
    Base.@deprecate_binding(parameter_upper_bound, _parameter_upper_bound, true,
        ", rewrite your code to use static parameters in dispatch or use `Base.rewrap_unionall((Base.unwrap_unionall(t)::DataType).parameters[idx], t)`.")
end # module TypeUtils
Base.@deprecate_binding TypeUtils TypeUtils false ", call the respective Base functions directly"
