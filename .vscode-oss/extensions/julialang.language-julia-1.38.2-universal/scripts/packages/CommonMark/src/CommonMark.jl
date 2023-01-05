module CommonMark

import JSON, URIs

include("utils.jl")
include("ast.jl")
include("parsers.jl")
include("writers.jl")
include("extensions.jl")

# Interface
export Parser, enable!, disable!, html, latex, term, markdown, notebook,
    frontmatter

# Core block rules
export
    AtxHeadingRule,
    BlockQuoteRule,
    FencedCodeBlockRule,
    HtmlBlockRule,
    IndentedCodeBlockRule,
    ListItemRule,
    SetextHeadingRule,
    ThematicBreakRule

# Core inline rules
export
    AsteriskEmphasisRule,
    AutolinkRule,
    HtmlEntityRule,
    HtmlInlineRule,
    ImageRule,
    InlineCodeRule,
    LinkRule,
    UnderscoreEmphasisRule

# Extension rules
export
    AdmonitionRule,
    AttributeRule,
    AutoIdentifierRule,
    CitationRule,
    DollarMathRule,
    FootnoteRule,
    FrontMatterRule,
    MathRule,
    RawContentRule,
    TableRule,
    TypographyRule

end # module
