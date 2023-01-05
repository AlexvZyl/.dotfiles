# terminals
isidentifier(x::EXPR) = headof(x) === :IDENTIFIER || headof(x) === :NONSTDIDENTIFIER
isoperator(x::EXPR) = headof(x) === :OPERATOR
isnonstdid(x::EXPR) = headof(x) === :NONSTDIDENTIFIER
iskeyword(x::EXPR) = headof(x) in (:ABSTRACT, :BAREMODULE, :BEGIN, :BREAK, :CATCH, :CONST, :CONTINUE, :DO, :ELSE, :ELSEIF, :END, :EXPORT, :FINALLY, :FOR, :FUNCTION, :GLOBAL, :IF, :IMPORT, :importall, :LET, :LOCAL, :MACRO, :MODULE, :MUTABLE, :NEW, :OUTER, :PRIMITIVE, :QUOTE, :RETURN, :STRUCT, :TRY, :TYPE, :USING, :WHILE)
isliteral(x::EXPR) = isstringliteral(x) || iscmd(x) || ischar(x) || headof(x) in (:INTEGER, :BININT, :HEXINT, :OCTINT, :FLOAT,  :NOTHING, :TRUE, :FALSE)
ispunctuation(x::EXPR) = is_comma(x) || is_lparen(x) || is_rparen(x) || is_lsquare(x) || is_rsquare(x) || is_lbrace(x) || is_rbrace(x) || headof(x) === :ATSIGN  || headof(x) === :DOT
isstringliteral(x) = headof(x) === :STRING || headof(x) === :TRIPLESTRING
isstring(x) = headof(x) === :string || isstringliteral(x)
iscmd(x) = headof(x) === :CMD || headof(x) === :TRIPLECMD
ischar(x) = headof(x) === :CHAR
isinteger(x) = headof(x) === :INTEGER
isfloat(x) = headof(x) === :FLOAT
isnumber(x) = isinteger(x) || isfloat(x)
is_nothing(x) = headof(x) === :NOTHING
is_either_id_op_interp(x::EXPR) = isidentifier(x) || isoperator(x) || isinterpolant(x)
is_id_or_macroname(x::EXPR) = isidentifier(x) || ismacroname(x)

# expressions
iscall(x::EXPR) = headof(x) === :call
isunarycall(x::EXPR) = (headof(x) === :call && length(x) == 2 && (isoperator(x.args[1]) || isoperator(x.args[2])))
isunarysyntax(x::EXPR) =  (isoperator(x.head) && length(x.args) == 1)
isbinarycall(x::EXPR) = headof(x) === :call && length(x) == 3 && isoperator(x.args[1])
isbinarycall(x::EXPR, op) = headof(x) === :call && length(x) == 3 && isoperator(x.args[1]) && valof(x.args[1]) == op
isbinarysyntax(x::EXPR) =  (isoperator(x.head) && length(x.args) == 2)
ischainedcall(x::EXPR) = headof(x) === :call && isoperator(x.args[1]) && (valof(x.args[1]) == "+" || valof(x.args[1]) == "*") && hastrivia(x) && isoperator(first(x.trivia))
iswhere(x::EXPR) = headof(x) === :where
istuple(x::EXPR) = headof(x) === :tuple
ismacrocall(x::EXPR) = headof(x) === :macrocall
ismacroname(x::EXPR) = (headof(x) === :NONSTDIDENTIFIER && startswith(valof(first(x.args)), "@") || (isidentifier(x) && valof(x) !== nothing && !isempty(valof(x)) && first(valof(x)) == '@')) || (is_getfield_w_quotenode(x) && (ismacroname(unquotenode(rhs_getfield(x))) || ismacroname(x.args[1])))

iskwarg(x::EXPR) = headof(x) === :kw
isparameters(x::EXPR) = headof(x) === :parameters
iscurly(x::EXPR) = headof(x) === :curly
isbracketed(x::EXPR) = headof(x) === :brackets


isassignment(x::EXPR) = isbinarysyntax(x) && valof(x.head) == "="
isdeclaration(x::EXPR) = isbinarysyntax(x) && valof(x.head) == "::"
isinterpolant(x::EXPR) = isunarysyntax(x) && valof(x.head) == "\$"
issplat(x::EXPR) = isunarysyntax(x) && valof(x.head) == "..."


isbeginorblock(x::EXPR) = headof(x) === :begin || headof(unwrapbracket(x)) == :block


"""
    is_getfield(x::EXPR)

Is this an expression of the form `a.b`.
"""
is_getfield(x::EXPR) = x.head isa EXPR && isoperator(x.head) && valof(x.head) == "." && length(x.args) == 2
is_getfield_w_quotenode(x) = is_getfield(x) && headof(x.args[2]) === :quotenode && length(x.args[2].args) > 0
rhs_getfield(x) = x.args[2]
unquotenode(x) = x.args[1]

function get_rhs_of_getfield(ret::EXPR)
    if headof(ret.args[2]) === :quotenode || headof(ret.args[2]) === :quote
        ret.args[2].args[1]
    else
        ret.args[2]
    end
end


"""
    is_wrapped_assignment(x::EXPR)

Is `x` an assignment expression, ignoring any surrounding parentheses.
"""
is_wrapped_assignment(x::EXPR) = isassignment(x) || (isbracketed(x) && is_wrapped_assignment(x.args[1]))


function is_func_call(x::EXPR)
    if isoperator(x.head) && !issplat(x)
        if length(x.args) == 2
            return is_decl(x.head) && is_func_call(x.args[1])
        elseif length(x.args) == 1
            return !(is_exor(x.head) || is_decl(x.head))
        end
    elseif x.head === :call
        return true
    elseif x.head === :where || isbracketed(x)
        return is_func_call(x.args[1])
    end
    return false
end


fcall_name(x::EXPR) = iscall(x) && length(x.args) > 0 && valof(x.args[1])
hasparent(x::EXPR) = parentof(x) isa EXPR

# OPERATOR
is_approx(x::EXPR) = isoperator(x) && valof(x) == "~"
is_exor(x) = isoperator(x) && valof(x) == "\$"
is_decl(x) = isoperator(x) && valof(x) == "::"
is_issubt(x) = isoperator(x) && valof(x) == "<:"
is_issupt(x) = isoperator(x) && valof(x) == ">:"
is_and(x) = isoperator(x) && valof(x) == "&"
is_not(x) = isoperator(x) && valof(x) == "!"
is_plus(x) = isoperator(x) && valof(x) == "+"
is_minus(x) = isoperator(x) && valof(x) == "-"
is_star(x) = isoperator(x) && valof(x) == "*"
is_eq(x) = isoperator(x) && valof(x) == "="
is_dot(x) = isoperator(x) && valof(x) == "."
is_ddot(x) = isoperator(x) && valof(x) == ".."
is_dddot(x) = isoperator(x) && valof(x) == "..."
is_pairarrow(x) = isoperator(x) && valof(x) == "=>"
is_in(x) = isoperator(x) && valof(x) == "in"
is_elof(x) = isoperator(x) && valof(x) == "∈"
is_colon(x) = isoperator(x) && valof(x) == ":"
is_prime(x) = isoperator(x) && maybe_strip_suffix(valof(x)) == "'"
is_cond(x) = isoperator(x) && valof(x) == "?"
is_where(x) = isoperator(x) && valof(x) == "where"
is_anon_func(x) = isoperator(x) && valof(x) == "->"

is_comma(x) = headof(x) === :COMMA
is_lparen(x) = headof(x) === :LPAREN
is_rparen(x) = headof(x) === :RPAREN
is_lbrace(x) = headof(x) === :LBRACE
is_rbrace(x) = headof(x) === :RBRACE
is_lsquare(x) = headof(x) === :LSQUARE
is_rsquare(x) = headof(x) === :RSQUARE

# KEYWORD
is_if(x) = iskeyword(x) && headof(x) === :IF
is_import(x) = iskeyword(x) && headof(x) === :IMPORT


# Literals

issubtypedecl(x::EXPR) = isoperator(x.head) && valof(x.head) == "<:"

rem_subtype(x::EXPR) = issubtypedecl(x) ? x.args[1] : x
rem_decl(x::EXPR) = isdeclaration(x) ? x.args[1] : x
rem_curly(x::EXPR) = headof(x) === :curly ? x.args[1] : x
rem_call(x::EXPR) = headof(x) === :call ? x.args[1] : x
rem_where(x::EXPR) = iswhere(x) ? x.args[1] : x
rem_wheres(x::EXPR) = iswhere(x) ? rem_wheres(x.args[1]) : x
rem_where_subtype(x::EXPR) = (iswhere(x) || issubtypedecl(x)) ? x.args[1] : x
rem_wheres_subtypes(x::EXPR) = (iswhere(x) || issubtypedecl(x)) ? rem_wheres_subtypes(x.args[1]) : x
rem_where_decl(x::EXPR) = (iswhere(x) || isdeclaration(x)) ? x.args[1] : x
rem_wheres_decls(x::EXPR) = (iswhere(x) || isdeclaration(x)) ? rem_wheres_decls(x.args[1]) : x
rem_invis(x::EXPR) = isbracketed(x) ? rem_invis(x.args[1]) : x
rem_dddot(x::EXPR) = issplat(x) ? x.args[1] : x
const rem_splat = rem_dddot
rem_kw(x::EXPR) = headof(x) === :kw ? x.args[1] : x
unwrapbracket(x::EXPR) = isbracketed(x) ? unwrapbracket(x.args[1]) : x

is_some_call(x) = headof(x) === :call || isunarycall(x)
is_eventually_some_call(x) = is_some_call(x) || ((isdeclaration(x) || iswhere(x)) && is_eventually_some_call(x.args[1]))

defines_function(x::EXPR) = headof(x) === :function || (isassignment(x) && is_eventually_some_call(x.args[1]))
defines_macro(x) = headof(x) == :macro
defines_datatype(x) = defines_struct(x) || defines_abstract(x) || defines_primitive(x)
defines_struct(x) = headof(x) === :struct
defines_mutable(x) = defines_struct(x) && x.args[1].head == :TRUE
defines_abstract(x) = headof(x) === :abstract
defines_primitive(x) = headof(x) === :primitive
defines_module(x) = headof(x) === :module
defines_anon_function(x) = isoperator(x.head) && valof(x.head) == "->"

has_sig(x::EXPR) = defines_datatype(x) || defines_function(x) || defines_macro(x) || defines_anon_function(x)

"""
    get_sig(x)

Returns the full signature of function, macro and datatype definitions.
Should only be called when has_sig(x) == true.
"""
function get_sig(x::EXPR)
    if headof(x) isa EXPR # headof(headof(x)) === :OPERATOR valof(headof(x)) == "="
        return x.args[1]
    elseif headof(x) === :struct || headof(x) === :mutable
        return x.args[2]
    elseif headof(x) === :abstract || headof(x) === :primitive || headof(x) === :function || headof(x) === :macro
        return x.args[1]
    end
end

function get_name(x::EXPR)
    if defines_datatype(x)
        sig = get_sig(x)
        sig = rem_subtype(sig)
        sig = rem_wheres(sig)
        sig = rem_subtype(sig)
        sig = rem_curly(sig)
    elseif defines_module(x)
        sig = x.args[2]
    elseif defines_function(x) || defines_macro(x)
        sig = get_sig(x)
        sig = rem_wheres(sig)
        sig = rem_decl(sig)
        sig = rem_call(sig)
        sig = rem_curly(sig)
        sig = rem_invis(sig)
        # if isbinarysyntax(sig) && is_dot(sig.head)
        if is_getfield_w_quotenode(sig)
            sig = sig.args[2].args[1]
        end
        return sig
    elseif is_getfield_w_quotenode(x)
        return x.args[2].args[1]
    elseif isbinarycall(x)
        sig = x.args[1]
        if isunarycall(sig)
            return get_name(sig.args[1])
        end
        sig = rem_wheres(sig)
        sig = rem_decl(sig)
        sig = rem_call(sig)
        sig = rem_curly(sig)
        sig = rem_invis(sig)
        return get_name(sig)
    elseif isbinarysyntax(x) && valof(x.head) == "<:"
        return get_name(x.args[1])
    elseif isunarysyntax(x) && valof(x.head) == "..."
        return get_name(x.args[1])
    else
        sig = x
        if isunarycall(sig)
            sig = sig.args[1]
        end
        sig = rem_wheres(sig)
        sig = rem_decl(sig)
        sig = rem_call(sig)
        sig = rem_curly(sig)
        rem_invis(sig)
    end
end

function get_arg_name(arg::EXPR)
    arg = rem_kw(arg)
    arg = rem_dddot(arg)
    arg = rem_where(arg)
    arg = rem_decl(arg)
    arg = rem_subtype(arg)
    arg = rem_curly(arg)
    rem_invis(arg)
end
