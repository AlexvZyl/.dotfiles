# Terminals
function julia_normalization_map(c::Int32, x::Ptr{Nothing})::Int32
    return c == 0x00B5 ? 0x03BC : # micro sign -> greek small letter mu
           c == 0x025B ? 0x03B5 : # latin small letter open e -> greek small letter
           c == 0x00B7 ? 0x22C5 :
           c == 0x0387 ? 0x22C5 :
           c == 0x2212 ? 0x002D :
           c
end

# Note: This code should be in julia base
function utf8proc_map_custom(str::String, options)
    norm_func = @cfunction julia_normalization_map Int32 (Int32, Ptr{Nothing})
    nwords = ccall(:utf8proc_decompose_custom, Int, (Ptr{UInt8}, Int, Ptr{UInt8}, Int, Cint, Ptr{Nothing}, Ptr{Nothing}),
                   str, sizeof(str), C_NULL, 0, options, norm_func, C_NULL)
    nwords < 0 && Base.Unicode.utf8proc_error(nwords)
    buffer = Base.StringVector(nwords * 4)
    nwords = ccall(:utf8proc_decompose_custom, Int, (Ptr{UInt8}, Int, Ptr{UInt8}, Int, Cint, Ptr{Nothing}, Ptr{Nothing}),
                   str, sizeof(str), buffer, nwords, options, norm_func, C_NULL)
    nwords < 0 && Base.Unicode.utf8proc_error(nwords)
    nbytes = ccall(:utf8proc_reencode, Int, (Ptr{UInt8}, Int, Cint), buffer, nwords, options)
    nbytes < 0 && Base.Unicode.utf8proc_error(nbytes)
    return String(resize!(buffer, nbytes))
end

function normalize_julia_identifier(str::AbstractString)
    options = Base.Unicode.UTF8PROC_STABLE | Base.Unicode.UTF8PROC_COMPOSE
    utf8proc_map_custom(String(str), options)
end


function sized_uint_literal(s::AbstractString, b::Integer)
    # We know integers are all ASCII, so we can use sizeof to compute
    # the length of ths string more quickly
    l = (sizeof(s) - 2) * b
    l <= 8   && return Base.parse(UInt8,   s)
    l <= 16  && return Base.parse(UInt16,  s)
    l <= 32  && return Base.parse(UInt32,  s)
    l <= 64  && return Base.parse(UInt64,  s)
    # l <= 128 && return Base.parse(UInt128, s)
    if l <= 128
        @static if VERSION >= v"1.1"
            return Expr(:macrocall, GlobalRef(Core, Symbol("@uint128_str")), nothing, s)
        else
            return Expr(:macrocall, Symbol("@uint128_str"), nothing, s)
        end
    end
    return Expr(:macrocall, GlobalRef(Core, Symbol("@big_str")), nothing, s)
end

function sized_uint_oct_literal(s::AbstractString)
    s[3] == 0 && return sized_uint_literal(s, 3)
    len = sizeof(s)
    (len < 5  || (len == 5  && s <= "0o377")) && return Base.parse(UInt8, s)
    (len < 8  || (len == 8  && s <= "0o177777")) && return Base.parse(UInt16, s)
    (len < 13 || (len == 13 && s <= "0o37777777777")) && return Base.parse(UInt32, s)
    (len < 24 || (len == 24 && s <= "0o1777777777777777777777")) && return Base.parse(UInt64, s)
    # (len < 45 || (len == 45 && s <= "0o3777777777777777777777777777777777777777777")) && return Base.parse(UInt128, s)
    # return Base.parse(BigInt, s)
    if (len < 45 || (len == 45 && s <= "0o3777777777777777777777777777777777777777777"))
        @static if VERSION >= v"1.1"
            return Expr(:macrocall, GlobalRef(Core, Symbol("@uint128_str")), nothing, s)
        else
            return Expr(:macrocall, Symbol("@uint128_str"), nothing, s)
        end
    end
    return Meta.parse(s)
end

function _literal_expr(x)
    if headof(x) === :TRUE
        return true
    elseif headof(x) === :FALSE
        return false
    elseif is_nothing(x)
        return nothing
    elseif headof(x) === :INTEGER || headof(x) === :BININT || headof(x) === :HEXINT || headof(x) === :OCTINT
        return Expr_int(x)
    elseif isfloat(x)
        return Expr_float(x)
    elseif ischar(x)
        return Expr_char(x)
    elseif headof(x) === :MACRO
        return Symbol(valof(x))
    elseif headof(x) === :STRING || headof(x) === :TRIPLESTRING
        return valof(x)
    elseif headof(x) === :CMD
        return Expr_cmd(x)
    elseif headof(x) === :TRIPLECMD
        return Expr_tcmd(x)
    end
end

const TYPEMAX_INT64_STR = string(typemax(Int))
const TYPEMAX_INT128_STR = string(typemax(Int128))
function Expr_int(x)
    is_hex = is_oct = is_bin = false
    val = replace(valof(x), "_" => "")
    if sizeof(val) > 2 && val[1] == '0'
        c = val[2]
        c == 'x' && (is_hex = true)
        c == 'o' && (is_oct = true)
        c == 'b' && (is_bin = true)
    end
    is_hex && return sized_uint_literal(val, 4)
    is_oct && return sized_uint_oct_literal(val)
    is_bin && return sized_uint_literal(val, 1)
    # sizeof(val) <= sizeof(TYPEMAX_INT64_STR) && return Base.parse(Int64, val)
    return Meta.parse(val)
    # # val < TYPEMAX_INT64_STR && return Base.parse(Int64, val)
    # sizeof(val) <= sizeof(TYPEMAX_INTval < TYPEMAX_INT128_STR128_STR) && return Base.parse(Int128, val)
    # # val < TYPEMAX_INT128_STR && return Base.parse(Int128, val)
    # Base.parse(BigInt, val)
end

function Expr_float(x)
    if !startswith(valof(x), "0x") && 'f' in valof(x)
        return Base.parse(Float32, replace(replace(valof(x), 'f' => 'e'), '_' => ""))
    end
    Base.parse(Float64, replace(valof(x), "_" => ""))
end
function Expr_char(x)
    val = _unescape_string(valof(x)[2:prevind(valof(x), lastindex(valof(x)))])
    # one byte e.g. '\xff' maybe not valid UTF-8
    # but we want to use the raw value as a codepoint in this case
    sizeof(val) == 1 && return Char(codeunit(val, 1))
    length(val) == 1 || error("Invalid character literal: $(Vector{UInt8}(valof(x)))")
    val[1]
end


# Expressions
to_codeobject(args...) = Expr(args...)

"""
    to_codeobject(x::EXPR)

Convert an `EXPR` into the object that `Meta.parse` would have produced from
the original string, which could e.g. be an `Expr`, `Symbol`, or literal.
"""
function to_codeobject(x::EXPR)
    if isidentifier(x)
        if headof(x) === :NONSTDIDENTIFIER
            if startswith(valof(x.args[1]), "@")
                Symbol("@", normalize_julia_identifier(valof(x.args[2])))
            else
                Symbol(normalize_julia_identifier(valof(x.args[2])))
            end
        else
            return Symbol(normalize_julia_identifier(valof(x)))
        end
    elseif iskeyword(x)
        if headof(x) === :BREAK
            return Expr(:break)
        elseif headof(x) === :CONTINUE
            return Expr(:continue)
        else
            return Symbol(lowercase(string(headof(x))))
        end
    elseif isoperator(x)
        return Symbol(normalize_julia_identifier(valof(x)))
    elseif ispunctuation(x)
        if headof(x) === :DOT
            if x.args === nothing
                return :(.)
            elseif length(x.args) == 1 && isoperator(x.args[1])
                return Expr(:(.), to_codeobject(x.args[1]))
            else
                Expr(:error)
            end
        else
            # We only reach this if we have a malformed expression.
            Expr(:error)
        end
    elseif isliteral(x)
        return _literal_expr(x)
    elseif isbracketed(x)
        return to_codeobject(x.args[1])
    elseif x.head isa EXPR
        Expr(to_codeobject(x.head), to_codeobject.(x.args)...)
    elseif x.head === :quotenode
        # quote nodes in import/using are unwrapped by the Julia parser
        if x.parent isa EXPR &&
            x.parent.parent isa EXPR &&
            is_dot(x.parent.head) &&
            x.parent.parent.head in (:import, :using)
            to_codeobject(x.args[1])
        else
            QuoteNode(to_codeobject(x.args[1]))
        end
    elseif x.head === :globalrefdoc
        GlobalRef(Core, Symbol("@doc"))
    elseif x.head === :globalrefcmd
        if VERSION >= v"1.1"
            GlobalRef(Core, Symbol("@cmd"))
        else
            Symbol("@cmd")
        end
    elseif x.head === :macrocall && is_getfield_w_quotenode(x.args[1]) && !ismacroname(x.args[1].args[2].args[1])
        # Shift '@' to the right
        valofrhs = valof(x.args[1].args[2].args[1])
        valofrhs = valofrhs === nothing ? "" : valofrhs
        new_name = Expr(:., remove_at(x.args[1].args[1]), QuoteNode(Symbol("@", valofrhs)))
        Expr(:macrocall, new_name, to_codeobject.(x.args[2:end])...)
    elseif x.head === :macrocall && isidentifier(x.args[1]) && valof(x.args[1]) == "@."
        Expr(:macrocall, Symbol("@__dot__"), to_codeobject.(x.args[2:end])...)
    elseif x.head === :macrocall && length(x.args) == 3 && x.args[1].head === :globalrefcmd && x.args[3].head == :string
        Expr(:macrocall, to_codeobject(x.args[1]), to_codeobject(x.args[2]), x.args[3].meta)
    elseif x.head === :string && length(x.args) > 0 && (x.args[1].head === :STRING || x.args[1].head === :TRIPLESTRING) && isempty(valof(x.args[1]))
        # Special conversion needed - the initial text section is treated as empty for the represented string following lowest-common-prefix adjustments, but exists in the source.
        Expr(:string, to_codeobject.(x.args[2:end])...)
    elseif x.args === nothing
        # for ncat/nrow etc
        int = tryparse(Int, String(x.head))
        int !== nothing && return int

        Expr(Symbol(lowercase(String(x.head))))
    elseif VERSION < v"1.7.0-DEV.1129" && x.head === :ncat
        dim = tryparse(Int, String(x.args[1].head))
        dim == nothing && return Expr(:error)
        head = dim == 1 ? :hcat : :vcat
        Expr(head, to_codeobject.(x.args[2:end])...)
    elseif x.head === :errortoken
        Expr(:error)
    else
        Expr(Symbol(lowercase(String(x.head))), to_codeobject.(x.args)...)
    end
end

function remove_at(x)
    if isidentifier(x) && valof(x) !== nothing && first(valof(x)) == '@'
        return Symbol(valof(x)[2:end])
    elseif is_getfield_w_quotenode(x)
        Expr(:., remove_at(x.args[1]), QuoteNode(remove_at(x.args[2].args[1])))
    else
        to_codeobject(x)
    end
end

# cross compatability for line number insertion in macrocalls
if VERSION > v"1.1-"
    Expr_cmd(x) = Expr(:macrocall, GlobalRef(Core, Symbol("@cmd")), nothing, valof(x))
    Expr_tcmd(x) = Expr(:macrocall, GlobalRef(Core, Symbol("@cmd")), nothing, valof(x))
else
    Expr_cmd(x) = Expr(:macrocall, Symbol("@cmd"), nothing, valof(x))
    Expr_tcmd(x) = Expr(:macrocall, Symbol("@cmd"), nothing, valof(x))
end


function clear_at!(x)
    if x isa Expr && x.head == :.
        if x.args[2] isa QuoteNode && string(x.args[2].value)[1] == '@'
            x.args[2].value = Symbol(string(x.args[2].value)[2:end])
        end
        if x.args[1] isa Symbol && string(x.args[1])[1] == '@'
            x.args[1] = Symbol(string(x.args[1])[2:end])
        else
            clear_at!(x.args[1])
        end
    end
end


"""
    remlineinfo!(x)
Removes line info expressions. (i.e. Expr(:line, 1))
"""
function remlineinfo!(x)
    if isa(x, Expr)
        if x.head == :macrocall && x.args[2] !== nothing
            id = findall(map(x -> (isa(x, Expr) && x.head == :line) || (@isdefined(LineNumberNode) && x isa LineNumberNode), x.args))
            deleteat!(x.args, id)
            for j in x.args
                remlineinfo!(j)
            end
            insert!(x.args, 2, nothing)
        else
            id = findall(map(x -> (isa(x, Expr) && x.head == :line) || (@isdefined(LineNumberNode) && x isa LineNumberNode), x.args))
            deleteat!(x.args, id)
            for j in x.args
                remlineinfo!(j)
            end
        end
        if x.head == :elseif && x.args[1] isa Expr && x.args[1].head == :block && length(x.args[1].args) == 1
            x.args[1] = x.args[1].args[1]
        end
    end
    x
end
