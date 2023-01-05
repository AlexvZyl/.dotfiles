function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    precompile(URIParser.parse_url, (String,))
    precompile(URIParser.parse_authority, (String, Bool,))
    precompile(URIParser.escape_with, (String, String,))
    precompile(URIParser.is_host_char, (Char,))
    precompile(URIParser.is_url_char, (Char,))
    precompile(URIParser.isnum, (Char,))
    precompile(URIParser.is_mark, (Char,))
    precompile(URIParser.is_userinfo_char, (Char,))
    precompile(URIParser.escape, (String,))
    precompile(URIParser.ishex, (Char,))
end
