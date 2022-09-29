@testset "Citations" begin
    p = enable!(Parser(), CitationRule())
    bib = JSON.parsefile(joinpath(@__DIR__, "citations.json"))

    test = function (bib, ast, _html, _latex, _markdown, _term)
        env = Dict{String,Any}("references" => bib)
        @test html(ast, env) == _html
        @test latex(ast, env) == _latex
        @test markdown(ast, env) == _markdown
        @test term(ast, env) == _term
    end

    # Unbracketed citations.

    # Missing bibliography data.
    test(
        bib,
        p("@unknown"),
        "<p><span class=\"citation\"><a href=\"#ref-unknown\">@unknown</a></span></p>\n",
        "\\protect\\hyperlink{ref-unknown}{@unknown}\\par\n",
        "@unknown\n",
        " \e[31m@unknown\e[39m\n",
    )

    # Single author.
    test(
        bib,
        p("@innes2018"),
        "<p><span class=\"citation\"><a href=\"#ref-innes2018\">Innes 2018</a></span></p>\n",
        "\\protect\\hyperlink{ref-innes2018}{Innes 2018}\\par\n",
        "@innes2018\n",
        " \e[31mInnes 2018\e[39m\n",
    )

    # Two authors.
    test(
        bib,
        p("@lubin2015"),
        "<p><span class=\"citation\"><a href=\"#ref-lubin2015\">Dunning and Lubin 2015</a></span></p>\n",
        "\\protect\\hyperlink{ref-lubin2015}{Dunning and Lubin 2015}\\par\n",
        "@lubin2015\n",
        " \e[31mDunning and Lubin 2015\e[39m\n",
    )

    # Many authors.
    test(
        bib,
        p("@bezanson2017"),
        "<p><span class=\"citation\"><a href=\"#ref-bezanson2017\">Bezanson et al. 2017</a></span></p>\n",
        "\\protect\\hyperlink{ref-bezanson2017}{Bezanson et al. 2017}\\par\n",
        "@bezanson2017\n",
        " \e[31mBezanson et al. 2017\e[39m\n",
    )

    # Bracketed citations.

    # Missing bibliography data.
    test(
        bib,
        p("[@unknown]"),
        "<p>(<span class=\"citation\"><a href=\"#ref-unknown\">@unknown</a></span>)</p>\n",
        "(\\protect\\hyperlink{ref-unknown}{@unknown})\\par\n",
        "[@unknown]\n",
        " (\e[31m@unknown\e[39m)\n",
    )

    # Single author.
    test(
        bib,
        p("[@innes2018]"),
        "<p>(<span class=\"citation\"><a href=\"#ref-innes2018\">Innes 2018</a></span>)</p>\n",
        "(\\protect\\hyperlink{ref-innes2018}{Innes 2018})\\par\n",
        "[@innes2018]\n",
        " (\e[31mInnes 2018\e[39m)\n",
    )

    # Two authors.
    test(
        bib,
        p("[@lubin2015]"),
        "<p>(<span class=\"citation\"><a href=\"#ref-lubin2015\">Dunning and Lubin 2015</a></span>)</p>\n",
        "(\\protect\\hyperlink{ref-lubin2015}{Dunning and Lubin 2015})\\par\n",
        "[@lubin2015]\n",
        " (\e[31mDunning and Lubin 2015\e[39m)\n",
    )

    # Many authors.
    test(
        bib,
        p("[@bezanson2017]"),
        "<p>(<span class=\"citation\"><a href=\"#ref-bezanson2017\">Bezanson et al. 2017</a></span>)</p>\n",
        "(\\protect\\hyperlink{ref-bezanson2017}{Bezanson et al. 2017})\\par\n",
        "[@bezanson2017]\n",
        " (\e[31mBezanson et al. 2017\e[39m)\n",
    )

    # Reference lists.
    p = enable!(Parser(), [CitationRule(), AttributeRule()])

    text =
    """
    {#refs}
    # The reference list.
    """
    test(
        bib,
        p(text),
        # Checked by hand.
        "<h1 id=\"refs\"><a href=\"#refs\" class=\"anchor\"></a>The reference list.</h1>\n<p id=\"ref-aruoba2015\">Aruoba, S. Borağan, and Jesús Fernández-Villaverde. 2015. <em>A comparison of programming languages in macroeconomics. </em></p>\n<p id=\"ref-cabutto2018\">Ault, Shaun V., Tyler A. Cabutto, Sean P. Heeney, Guifen Mao, and Jin Wang. 2018. <em>An Overview of the Julia Programming Language. </em></p>\n<p id=\"ref-besard2018\">Besard, Tim, Bjorn De Sutter, and Christophe Foket. 2018. <em>Effective extensible programming: Unleashing julia on gpus. </em></p>\n<p id=\"ref-bezanson2017\">Bezanson, Jeff, Alan Edelman, Stefan Karpinski, and Viral B. Shah. 2017. <em>Julia: A fresh approach to numerical computing. </em></p>\n<p id=\"ref-bezanson2012\">Bezanson, Jeff, Alan Edelman, Stefan Karpinski, and Viral B. Shah. 2012. <em>Julia: A fast dynamic language for technical computing. </em></p>\n<p id=\"ref-udell2014\">Boyd, Stephen, Steven Diamond, Jenny Hong, Karanveer Mohan, Madeleine Udell, and David Zeng. 2014. <em>Convex optimization in Julia. </em>IEEE. </p>\n<p id=\"ref-chen2016\">Chen, Jiahao, and Jarrett Revels. 2016. <em>Robust benchmarking in noisy environments. </em></p>\n<p id=\"ref-cusumano-towner2019\">Cusumano-Towner, Marco F., Alexander K. Lew, Vikash K. Mansinghka, and Feras A. Saad. 2019. <em>Gen: A general-purpose probabilistic programming system with programmable inference. </em>New York, NY, USA: ACM. doi:10.1145/3314221.3314642. <a href=\"http://doi.acm.org/10.1145/3314221.3314642\" title=\"http://doi.acm.org/10.1145/3314221.3314642\">http://doi.acm.org/10.1145/3314221.3314642</a>. </p>\n<p id=\"ref-lubin2015\">Dunning, Iain, and Miles Lubin. 2015. <em>Computing in operations research using Julia. </em></p>\n<p id=\"ref-edelman2015\">Edelman, Alan. 2015. <em>Julia: A fresh approach to parallel programming. </em>IEEE. </p>\n<p id=\"ref-elmqvist2016\">Elmqvist, Hilding, Toivo Henningsson, and Martin Otter. 2016. <em>Systems modeling and programming in a unified environment based on Julia. </em>Springer. </p>\n<p id=\"ref-fieker2017\">Fieker, Claus, William Hart, Tommy Hofmann, and Fredrik Johansson. 2017. <em>Nemo/Hecke: computer algebra and number theory packages for the Julia programming language. </em></p>\n<p id=\"ref-innes2018a\">Fischer, Keno, Dhairya Gandhi, Michael Innes, Neethu Mariya Joy, Tejan Karmali, Avik Pal, Marco Concetto Rudilosso, Elliot Saba, and Viral Shah. 2018. <em>Fashionable modelling with flux. </em><a href=\"http://arxiv.org/abs/1811.01457\" title=\"http://arxiv.org/abs/1811.01457\">http://arxiv.org/abs/1811.01457</a>. </p>\n<p id=\"ref-ge2018\">Ge, Hong, Zoubin Ghahramani, and Kai Xu. 2018. <em>Turing: a language for flexible probabilistic inference. </em><a href=\"http://proceedings.mlr.press/v84/ge18b.html\" title=\"http://proceedings.mlr.press/v84/ge18b.html\">http://proceedings.mlr.press/v84/ge18b.html</a>. </p>\n<p id=\"ref-innes2018\">Innes, Michael. 2018. <em>Don't unroll adjoint: Differentiating SSA-Form programs. </em><a href=\"http://arxiv.org/abs/1810.07951\" title=\"http://arxiv.org/abs/1810.07951\">http://arxiv.org/abs/1810.07951</a>. </p>\n<p id=\"ref-innes2018b\">Innes, Mike. 2018. <em>Flux: Elegant machine learning with julia. </em>doi:10.21105/joss.00602. </p>\n<p id=\"ref-masthay2017\">Masthay, Tyler M., and Saverio Perugini. 2017. <em>Parareal Algorithm Implementation and Simulation in Julia. </em></p>\n<p id=\"ref-mogensen2018\">Mogensen, Patrick Kofod, and Asbjørn Nilsen Riseth. 2018. <em>Optim: A mathematical optimization package for Julia. </em></p>\n<p id=\"ref-rackauckas2017\">Nie, Qing, and Christopher Rackauckas. 2017. <em>DifferentialEquations.jl – a performant and feature-rich ecosystem for solving differential equations in julia. </em>doi:10.5334/jors.151. <a href=\"https://app.dimensions.ai/details/publication/pub.1085583166\" title=\"https://app.dimensions.ai/details/publication/pub.1085583166\">https://app.dimensions.ai/details/publication/pub.1085583166</a>. </p>\n<p id=\"ref-novosel2019\">Novosel, Rok, and Bostjan Slivnik. 2019. <em>Beyond Classical Parallel Programming Frameworks: Chapel vs Julia. </em>Schloss Dagstuhl-Leibniz-Zentrum fuer Informatik. </p>\n",
        "\\protect\\hypertarget{refs}{}\n\\section{The reference list.}\n\\protect\\hypertarget{ref-aruoba2015}{}Aruoba, S. Borağan, and Jesús Fernández-Villaverde. 2015. \\textit{A comparison of programming languages in macroeconomics. }\\par\n\\protect\\hypertarget{ref-cabutto2018}{}Ault, Shaun V., Tyler A. Cabutto, Sean P. Heeney, Guifen Mao, and Jin Wang. 2018. \\textit{An Overview of the Julia Programming Language. }\\par\n\\protect\\hypertarget{ref-besard2018}{}Besard, Tim, Bjorn De Sutter, and Christophe Foket. 2018. \\textit{Effective extensible programming: Unleashing julia on gpus. }\\par\n\\protect\\hypertarget{ref-bezanson2017}{}Bezanson, Jeff, Alan Edelman, Stefan Karpinski, and Viral B. Shah. 2017. \\textit{Julia: A fresh approach to numerical computing. }\\par\n\\protect\\hypertarget{ref-bezanson2012}{}Bezanson, Jeff, Alan Edelman, Stefan Karpinski, and Viral B. Shah. 2012. \\textit{Julia: A fast dynamic language for technical computing. }\\par\n\\protect\\hypertarget{ref-udell2014}{}Boyd, Stephen, Steven Diamond, Jenny Hong, Karanveer Mohan, Madeleine Udell, and David Zeng. 2014. \\textit{Convex optimization in Julia. }IEEE. \\par\n\\protect\\hypertarget{ref-chen2016}{}Chen, Jiahao, and Jarrett Revels. 2016. \\textit{Robust benchmarking in noisy environments. }\\par\n\\protect\\hypertarget{ref-cusumano-towner2019}{}Cusumano-Towner, Marco F., Alexander K. Lew, Vikash K. Mansinghka, and Feras A. Saad. 2019. \\textit{Gen: A general-purpose probabilistic programming system with programmable inference. }New York, NY, USA: ACM. doi:10.1145/3314221.3314642. \\href{http://doi.acm.org/10.1145/3314221.3314642}{http://doi.acm.org/10.1145/3314221.3314642}. \\par\n\\protect\\hypertarget{ref-lubin2015}{}Dunning, Iain, and Miles Lubin. 2015. \\textit{Computing in operations research using Julia. }\\par\n\\protect\\hypertarget{ref-edelman2015}{}Edelman, Alan. 2015. \\textit{Julia: A fresh approach to parallel programming. }IEEE. \\par\n\\protect\\hypertarget{ref-elmqvist2016}{}Elmqvist, Hilding, Toivo Henningsson, and Martin Otter. 2016. \\textit{Systems modeling and programming in a unified environment based on Julia. }Springer. \\par\n\\protect\\hypertarget{ref-fieker2017}{}Fieker, Claus, William Hart, Tommy Hofmann, and Fredrik Johansson. 2017. \\textit{Nemo/Hecke: computer algebra and number theory packages for the Julia programming language. }\\par\n\\protect\\hypertarget{ref-innes2018a}{}Fischer, Keno, Dhairya Gandhi, Michael Innes, Neethu Mariya Joy, Tejan Karmali, Avik Pal, Marco Concetto Rudilosso, Elliot Saba, and Viral Shah. 2018. \\textit{Fashionable modelling with flux. }\\href{http://arxiv.org/abs/1811.01457}{http://arxiv.org/abs/1811.01457}. \\par\n\\protect\\hypertarget{ref-ge2018}{}Ge, Hong, Zoubin Ghahramani, and Kai Xu. 2018. \\textit{Turing: a language for flexible probabilistic inference. }\\href{http://proceedings.mlr.press/v84/ge18b.html}{http://proceedings.mlr.press/v84/ge18b.html}. \\par\n\\protect\\hypertarget{ref-innes2018}{}Innes, Michael. 2018. \\textit{Don't unroll adjoint: Differentiating SSA-Form programs. }\\href{http://arxiv.org/abs/1810.07951}{http://arxiv.org/abs/1810.07951}. \\par\n\\protect\\hypertarget{ref-innes2018b}{}Innes, Mike. 2018. \\textit{Flux: Elegant machine learning with julia. }doi:10.21105/joss.00602. \\par\n\\protect\\hypertarget{ref-masthay2017}{}Masthay, Tyler M., and Saverio Perugini. 2017. \\textit{Parareal Algorithm Implementation and Simulation in Julia. }\\par\n\\protect\\hypertarget{ref-mogensen2018}{}Mogensen, Patrick Kofod, and Asbjørn Nilsen Riseth. 2018. \\textit{Optim: A mathematical optimization package for Julia. }\\par\n\\protect\\hypertarget{ref-rackauckas2017}{}Nie, Qing, and Christopher Rackauckas. 2017. \\textit{DifferentialEquations.jl – a performant and feature-rich ecosystem for solving differential equations in julia. }doi:10.5334/jors.151. \\href{https://app.dimensions.ai/details/publication/pub.1085583166}{https://app.dimensions.ai/details/publication/pub.1085583166}. \\par\n\\protect\\hypertarget{ref-novosel2019}{}Novosel, Rok, and Bostjan Slivnik. 2019. \\textit{Beyond Classical Parallel Programming Frameworks: Chapel vs Julia. }Schloss Dagstuhl-Leibniz-Zentrum fuer Informatik. \\par\n",
        "{#refs}\n# The reference list.\n\n",
        " \e[34;1m#\e[39;22m The reference list.\n \n Aruoba, S. Borağan, and Jesús Fernández-Villaverde. 2015. \e[3mA comparison of\n\e[23m \e[3mprogramming languages in macroeconomics. \e[23m\n \n Ault, Shaun V., Tyler A. Cabutto, Sean P. Heeney, Guifen Mao, and Jin Wang. \n 2018. \e[3mAn Overview of the Julia Programming Language. \e[23m\n \n Besard, Tim, Bjorn De Sutter, and Christophe Foket. 2018. \e[3mEffective\n\e[23m \e[3mextensible programming: Unleashing julia on gpus. \e[23m\n \n Bezanson, Jeff, Alan Edelman, Stefan Karpinski, and Viral B. Shah. 2017. \e[3m\n\e[23m \e[3mJulia: A fresh approach to numerical computing. \e[23m\n \n Bezanson, Jeff, Alan Edelman, Stefan Karpinski, and Viral B. Shah. 2012. \e[3m\n\e[23m \e[3mJulia: A fast dynamic language for technical computing. \e[23m\n \n Boyd, Stephen, Steven Diamond, Jenny Hong, Karanveer Mohan, Madeleine Udell,\n and David Zeng. 2014. \e[3mConvex optimization in Julia. \e[23mIEEE. \n \n Chen, Jiahao, and Jarrett Revels. 2016. \e[3mRobust benchmarking in noisy\n\e[23m \e[3menvironments. \e[23m\n \n Cusumano-Towner, Marco F., Alexander K. Lew, Vikash K. Mansinghka, and Feras\n A. Saad. 2019. \e[3mGen: A general-purpose probabilistic programming system with\n\e[23m \e[3mprogrammable inference. \e[23mNew York, NY, USA: ACM. doi:10.1145/3314221.3314642. \e[34;4m\n\e[39;24m \e[34;4mhttp://doi.acm.org/10.1145/3314221.3314642\e[39;24m. \n \n Dunning, Iain, and Miles Lubin. 2015. \e[3mComputing in operations research using\n\e[23m \e[3mJulia. \e[23m\n \n Edelman, Alan. 2015. \e[3mJulia: A fresh approach to parallel programming. \e[23mIEEE. \n \n Elmqvist, Hilding, Toivo Henningsson, and Martin Otter. 2016. \e[3mSystems\n\e[23m \e[3mmodeling and programming in a unified environment based on Julia. \e[23mSpringer. \n \n Fieker, Claus, William Hart, Tommy Hofmann, and Fredrik Johansson. 2017. \e[3m\n\e[23m \e[3mNemo/Hecke: computer algebra and number theory packages for the Julia\n\e[23m \e[3mprogramming language. \e[23m\n \n Fischer, Keno, Dhairya Gandhi, Michael Innes, Neethu Mariya Joy, Tejan\n Karmali, Avik Pal, Marco Concetto Rudilosso, Elliot Saba, and Viral Shah. \n 2018. \e[3mFashionable modelling with flux. \e[23m\e[34;4mhttp://arxiv.org/abs/1811.01457\e[39;24m. \n \n Ge, Hong, Zoubin Ghahramani, and Kai Xu. 2018. \e[3mTuring: a language for\n\e[23m \e[3mflexible probabilistic inference. \e[23m\e[34;4mhttp://proceedings.mlr.press/v84/ge18b.html\e[39;24m.\n \n \n Innes, Michael. 2018. \e[3mDon't unroll adjoint: Differentiating SSA-Form\n\e[23m \e[3mprograms. \e[23m\e[34;4mhttp://arxiv.org/abs/1810.07951\e[39;24m. \n \n Innes, Mike. 2018. \e[3mFlux: Elegant machine learning with julia. \e[23m\n doi:10.21105/joss.00602. \n \n Masthay, Tyler M., and Saverio Perugini. 2017. \e[3mParareal Algorithm\n\e[23m \e[3mImplementation and Simulation in Julia. \e[23m\n \n Mogensen, Patrick Kofod, and Asbjørn Nilsen Riseth. 2018. \e[3mOptim: A\n\e[23m \e[3mmathematical optimization package for Julia. \e[23m\n \n Nie, Qing, and Christopher Rackauckas. 2017. \e[3mDifferentialEquations.jl – a\n\e[23m \e[3mperformant and feature-rich ecosystem for solving differential equations in\n\e[23m \e[3mjulia. \e[23mdoi:10.5334/jors.151. \e[34;4m\n\e[39;24m \e[34;4mhttps://app.dimensions.ai/details/publication/pub.1085583166\e[39;24m. \n \n Novosel, Rok, and Bostjan Slivnik. 2019. \e[3mBeyond Classical Parallel\n\e[23m \e[3mProgramming Frameworks: Chapel vs Julia. \e[23mSchloss Dagstuhl-Leibniz-Zentrum\n fuer Informatik. \n"
    )
end
