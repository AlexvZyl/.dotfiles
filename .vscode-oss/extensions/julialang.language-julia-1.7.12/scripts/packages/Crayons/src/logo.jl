function print_logo(io = stdout)
    c = string(Crayon(foreground = :light_red))
    r = string(Crayon(foreground = :light_green))
    a = string(Crayon(foreground = :light_yellow))
    y = string(Crayon(foreground = :light_blue))
    o = string(Crayon(foreground = :light_magenta))
    n = string(Crayon(foreground = :light_cyan))
    s = string(Crayon(foreground = :dark_gray))
    res = string(Crayon(reset = true))

    str = """
       $(c)██████╗$(r)██████╗  $(a)█████╗ $(y)██╗   ██╗ $(o)██████╗ $(n)███╗   ██╗$(s)███████╗
      $(c)██╔════╝$(r)██╔══██╗$(a)██╔══██╗$(y)╚██╗ ██╔╝$(o)██╔═══██╗$(n)████╗  ██║$(s)██╔════╝
      $(c)██║     $(r)██████╔╝$(a)███████║ $(y)╚████╔╝ $(o)██║   ██║$(n)██╔██╗ ██║$(s)███████╗
      $(c)██║     $(r)██╔══██╗$(a)██╔══██║  $(y)╚██╔╝  $(o)██║   ██║$(n)██║╚██╗██║$(s)╚════██║
      $(c)╚██████╗$(r)██║  ██║$(a)██║  ██║   $(y)██║   $(o)╚██████╔╝$(n)██║ ╚████║$(s)███████║
       $(c)╚═════╝$(r)╚═╝  ╚═╝$(a)╚═╝  ╚═╝   $(y)╚═╝    $(o)╚═════╝ $(n)╚═╝  ╚═══╝$(s)╚══════╝$(res)
    """

    print(io, "\n\n", str, "\n")
end



