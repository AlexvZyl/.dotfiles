@testset "Tables" begin
    p = Parser()
    enable!(p, TableRule())

    text =
    """
    | 1 | 10 | 100 |
    | - | --:|:---:|
    | x | y  | z   |
    """
    ast = p(text)

    # HTML
    @test html(ast) == "<table><thead><tr><th align=\"left\">1</th><th align=\"right\">10</th><th align=\"center\">100</th></tr></thead><tbody><tr><td align=\"left\">x</td><td align=\"right\">y</td><td align=\"center\">z</td></tr></tbody></table>"
    @test latex(ast) == "\\begin{longtable}[]{@{}lrc@{}}\n\\hline\n1 & 10 & 100\\tabularnewline\n\\hline\n\\endfirsthead\nx & y & z\\tabularnewline\n\\hline\n\\end{longtable}\n"
    @test term(ast) == " ┏━━━┯━━━━┯━━━━━┓\n ┃ 1 │ 10 │ 100 ┃\n ┠───┼────┼─────┨\n ┃ x │  y │  z  ┃\n ┗━━━┷━━━━┷━━━━━┛\n"
    @test markdown(ast) == "| 1 | 10 | 100 |\n|:- | --:|:---:|\n| x | y  | z   |\n"
    @test markdown(p(markdown(ast))) == "| 1 | 10 | 100 |\n|:- | --:|:---:|\n| x | y  | z   |\n"

    # Mis-aligned table pipes:
    text =
    """
    |1|10|100|
    | - | --:|:---:|
    |x|y|z|
    """
    ast = p(text)
    @test html(ast) == "<table><thead><tr><th align=\"left\">1</th><th align=\"right\">10</th><th align=\"center\">100</th></tr></thead><tbody><tr><td align=\"left\">x</td><td align=\"right\">y</td><td align=\"center\">z</td></tr></tbody></table>"

    p = enable!(Parser(), [TableRule(), AttributeRule()])

    text =
    """
    {#id}
    | 1 | 10 | 100 |
    | - | --:|:---:|
    | x | y  | z   |
    """
    ast = p(text)

    # HTML
    @test html(ast) == "<table id=\"id\"><thead><tr><th align=\"left\">1</th><th align=\"right\">10</th><th align=\"center\">100</th></tr></thead><tbody><tr><td align=\"left\">x</td><td align=\"right\">y</td><td align=\"center\">z</td></tr></tbody></table>"
    @test latex(ast) == "\\protect\\hypertarget{id}{}\\begin{longtable}[]{@{}lrc@{}}\n\\hline\n1 & 10 & 100\\tabularnewline\n\\hline\n\\endfirsthead\nx & y & z\\tabularnewline\n\\hline\n\\end{longtable}\n"

    # Internal pipes:
    text =
    """
    |1|10|`|`|
    | -:| - |:-:|
    |*|*|![|](url)|
    |1|2|3|4|
    """
    ast = p(text)

    @test html(ast) == "<table><thead><tr><th align=\"right\">1</th><th align=\"left\">10</th><th align=\"center\"><code>|</code></th></tr></thead><tbody><tr><td align=\"right\"><em>|</em></td><td align=\"left\"><img src=\"url\" alt=\"|\" /></td><td align=\"left\"></td></tr><tr><td align=\"right\">1</td><td align=\"left\">2</td><td align=\"center\">3</td></tr></tbody></table>"
    @test latex(ast) == "\\begin{longtable}[]{@{}rlc@{}}\n\\hline\n1 & 10 & \\texttt{|}\\tabularnewline\n\\hline\n\\endfirsthead\n\\textit{|} & \n\\begin{figure}\n\\centering\n\\includegraphics[max width=\\linewidth]{url}\n\\caption{|}\n\\end{figure}\n & \\tabularnewline\n1 & 2 & 3\\tabularnewline\n\\hline\n\\end{longtable}\n"
    @test term(ast) == " ┏━━━┯━━━━┯━━━┓\n ┃ 1 │ 10 │ \e[36m|\e[39m ┃\n ┠───┼────┼───┨\n ┃ \e[3m|\e[23m │ \e[32m|\e[39m  │   ┃\n ┃ 1 │ 2  │ 3 ┃\n ┗━━━┷━━━━┷━━━┛\n"
    @test markdown(ast) == "| 1   | 10        | `|` |\n| ---:|:--------- |:---:|\n| *|* | ![|](url) |     |\n| 1   | 2         | 3   |\n"

    # Empty columns:
    text =
    """
    |||
    |-|-|
    |||
    """
    ast = p(text)

    @test html(ast) == "<table><thead><tr><th align=\"left\"></th><th align=\"left\"></th></tr></thead><tbody><tr><td align=\"left\"></td><td align=\"left\"></td></tr></tbody></table>"
    @test latex(ast) == "\\begin{longtable}[]{@{}ll@{}}\n\\hline\n & \\tabularnewline\n\\hline\n\\endfirsthead\n & \\tabularnewline\n\\hline\n\\end{longtable}\n"
    @test term(ast) == " ┏━━━┯━━━┓\n ┃   │   ┃\n ┠───┼───┨\n ┃   │   ┃\n ┗━━━┷━━━┛\n"
    @test markdown(ast) == "|   |   |\n|:- |:- |\n|   |   |\n"

    text =
    """
    # Header

    | table |
    | ----- |
    | content |
    """
    ast = p(text)

    @test html(ast) == "<h1>Header</h1>\n<table><thead><tr><th align=\"left\">table</th></tr></thead><tbody><tr><td align=\"left\">content</td></tr></tbody></table>"
    @test latex(ast) == "\\section{Header}\n\\begin{longtable}[]{@{}l@{}}\n\\hline\ntable\\tabularnewline\n\\hline\n\\endfirsthead\ncontent\\tabularnewline\n\\hline\n\\end{longtable}\n"
    @test term(ast) == " \e[34;1m#\e[39;22m Header\n \n ┏━━━━━━━━━┓\n ┃ table   ┃\n ┠─────────┨\n ┃ content ┃\n ┗━━━━━━━━━┛\n"
    @test markdown(ast) == "# Header\n\n| table   |\n|:------- |\n| content |\n"

    # 'messy' tables

    text =
    """
    # Messy tables

    | table
    | :-: |
    | *|*
    """
    ast = p(text)

    @test html(ast) == "<h1>Messy tables</h1>\n<table><thead><tr><th align=\"center\">table</th></tr></thead><tbody><tr><td align=\"center\"><em>|</em></td></tr></tbody></table>"
    @test latex(ast) == "\\section{Messy tables}\n\\begin{longtable}[]{@{}c@{}}\n\\hline\ntable\\tabularnewline\n\\hline\n\\endfirsthead\n\\textit{|}\\tabularnewline\n\\hline\n\\end{longtable}\n"
    @test term(ast) == " \e[34;1m#\e[39;22m Messy tables\n \n ┏━━━━━━━┓\n ┃ table ┃\n ┠───────┨\n ┃   \e[3m|\e[23m   ┃\n ┗━━━━━━━┛\n"
    @test markdown(ast) == "# Messy tables\n\n| table |\n|:-----:|\n| *|*   |\n"


    # tables with lots of whitespace

    text =
    """
    # whitespace (#38)

    | 1         | 2         | 3       |       4 |
    |   :--:    |   :--     |   ---   |   -:    |
    | one       | two       |   three |   four  |
    """
    ast = p(text)

    @test html(ast) == "<h1>whitespace (#38)</h1>\n<table><thead><tr><th align=\"center\">1</th><th align=\"left\">2</th><th align=\"left\">3</th><th align=\"right\">4</th></tr></thead><tbody><tr><td align=\"center\">one</td><td align=\"left\">two</td><td align=\"left\">three</td><td align=\"right\">four</td></tr></tbody></table>"
    @test latex(ast) == "\\section{whitespace (\\#38)}\n\\begin{longtable}[]{@{}cllr@{}}\n\\hline\n1 & 2 & 3 & 4\\tabularnewline\n\\hline\n\\endfirsthead\none & two & three & four\\tabularnewline\n\\hline\n\\end{longtable}\n"
    @test term(ast) == " \e[34;1m#\e[39;22m whitespace (#38)\n \n ┏━━━━━┯━━━━━┯━━━━━━━┯━━━━━━┓\n ┃  1  │ 2   │ 3     │    4 ┃\n ┠─────┼─────┼───────┼──────┨\n ┃ one │ two │ three │ four ┃\n ┗━━━━━┷━━━━━┷━━━━━━━┷━━━━━━┛\n"
    @test markdown(ast) == "# whitespace (#38)\n\n| 1   | 2   | 3     | 4    |\n|:---:|:--- |:----- | ----:|\n| one | two | three | four |\n"
end
