function test_styles(io::IO = stdout)
    for style in (:bold,
                  :faint,
                  :italics,
                  :underline,
                  :blink,
                  :negative,
                  :conceal,
                  :strikethrough)
        print(io, Crayon(;style => true), "Printed with $style = true", Crayon(reset = true))
        style == :conceal && print(io, "  <- This is concealed = true")
        println(io)
    end
end

function test_system_colors(io::IO = stdout)
    for col in map(first,sort(collect(COLORS), by=last))
        print(io, Crayon(foreground = col), lpad("$col", 15, ' '), " ", Crayon(reset = true))
        print(io, Crayon(background = col), col, Crayon(reset = true), "\n")
    end
end

test_256_colors(codes::Bool = true) = test_256_colors(stdout, codes)
test_256_colors(io::IO) = test_256_colors(io, true)
function test_256_colors(io::IO, codes::Bool)
    println(io, "System colors (0..15):")

    for c in 0:15
        str = codes ? string(lpad(c, 3, '0'), " ") : "██"
        print(io, Crayon(foreground = c), str, Crayon(reset = true))
        (c + 1) % 8 == 0 && println(io)
    end
    print(io, "\n\n")

    println(io, "Color cube, 6×6×6 (16..231):")
    for c in 16:231
        str = codes ? string(lpad(c, 3, '0'), " ") : "██"
        print(io, Crayon(foreground = c), str, Crayon(reset = true))
        (c - 16) %  6 ==  5 && println(io)
        (c - 16) % 36 == 35 && println(io)
    end

    println(io, "Grayscale ramp (232..255):")
    for c in 232:255
        str = codes ? string(lpad(c, 3, '0'), " ") : "██"
        print(io, Crayon(foreground = c), str, Crayon(reset = true))
        (c - 232) %  6 == 5 && println(io)
    end
end

test_24bit_colors(codes::Bool = true) = test_24bit_colors(stdout, codes)
test_24bit_colors(io::IO) = test_24bit_colors(io, true)
function test_24bit_colors(io::IO, codes::Bool)
    steps = 0:30:255
    for r in steps
        for g in steps
            for b in steps
                str = codes ? string(lpad(r, 3, '0'), "|", lpad(g, 3, '0'), "|", lpad(b, 3, '0'), " ") : "██"
                print(io, Crayon(; foreground = (r, g, b)), str, Crayon(reset = true))
            end
            println(io)
        end
        println(io)
    end
end
