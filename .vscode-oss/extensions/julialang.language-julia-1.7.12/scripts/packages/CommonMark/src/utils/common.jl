# TODO: entity regex #[0-9]{1,8} not technically correct, should be #[0-9]{1,7}
# but this seems to be required for passing one of the sample cases from cmark.
const ENTITY                = "&(?:#x[a-f0-9]{1,6}|#[0-9]{1,8}|[a-z][a-z0-9]{1,31});"
const TAGNAME               = "[A-Za-z][A-Za-z0-9-]*"
const ATTRIBUTENAME         = "[a-zA-Z_:][a-zA-Z0-9:._-]*"
const UNQUOTEDVALUE         = "[^\"'=<>`\\x00-\\x20]+"
const SINGLEQUOTEDVALUE     = "'[^']*'"
const DOUBLEQUOTEDVALUE     = "\"[^\"]*\""
const ATTRIBUTEVALUE        = "(?:$(UNQUOTEDVALUE)|$(SINGLEQUOTEDVALUE)|$(DOUBLEQUOTEDVALUE))"
const ATTRIBUTEVALUESPEC    = "(?:\\s*=\\s*$(ATTRIBUTEVALUE))"
const ATTRIBUTE             = "(?:\\s+$(ATTRIBUTENAME)$(ATTRIBUTEVALUESPEC)?)"
const OPENTAG               = "<$(TAGNAME)$(ATTRIBUTE)*\\s*/?>"
const CLOSETAG              = "</$(TAGNAME)\\s*[>]"
const HTMLCOMMENT           = "<!---->|<!--(?:-?[^>-])(?:-?[^-])*-->"
const PROCESSINGINSTRUCTION = "[<][?].*?[?][>]"
const DECLARATION           = "<![A-Z]+\\s+[^>]*>"
const CDATA                 = "<!\\[CDATA\\[[\\s\\S]*?\\]\\]>"
const HTMLTAG               = "(?:$(OPENTAG)|$(CLOSETAG)|$(HTMLCOMMENT)|$(PROCESSINGINSTRUCTION)|$(DECLARATION)|$(CDATA))"
const ESCAPABLE             = "[!\"#\$%&\'()*+,./:;<=>?@[\\\\\\]^_`{|}~-]"
const XMLSPECIAL            = "[&<>\"]"

const reHtmlTag             = Regex("^$(HTMLTAG)", "i")
const reBackslashOrAmp      = r"[\\&]"
const reEntityOrEscapedChar = Regex("\\\\$(ESCAPABLE)|$(ENTITY)", "i")
const reXmlSpecial          = Regex(XMLSPECIAL)

unescape_char(s) = s[1] == '\\' ? s[2] : HTMLunescape(s)

unescape_string(s) = occursin(reBackslashOrAmp, s) ?
    replace(s, reEntityOrEscapedChar =>  unescape_char) : s

@inline issafe(c::Char) = c in "?:/,-+@._()#=*&%" || (isascii(c) && (isletter(c) || isnumeric(c)))
normalize_uri(s::AbstractString) = URIs.escapeuri(s, issafe)

const UNSAFE_MAP = Dict(
    "&"  => "&amp;",
    "<"  => "&lt;",
    ">"  => "&gt;",
    "\"" => "&quot;",
)
replace_unsafe_char(s::AbstractString) = get(UNSAFE_MAP, s, s)

escape_xml(::Nothing) = ""
escape_xml(c::AbstractChar) = escape_xml(string(c))
escape_xml(s::AbstractString) = occursin(reXmlSpecial, s) ?
    replace(s, reXmlSpecial => replace_unsafe_char) : s
