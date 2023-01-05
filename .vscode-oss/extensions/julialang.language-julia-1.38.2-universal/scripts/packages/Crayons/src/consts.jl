module Box

using Crayons

export BLACK_FG,
RED_FG,
GREEN_FG,
YELLOW_FG,
BLUE_FG,
MAGENTA_FG,
CYAN_FG,
LIGHT_GRAY_FG,
DEFAULT_FG,
DARK_GRAY_FG,
LIGHT_RED_FG,
LIGHT_GREEN_FG,
LIGHT_YELLOW_FG,
LIGHT_BLUE_FG,
LIGHT_MAGENTA_FG,
LIGHT_CYAN_FG,
WHITE_FG,
BLACK_BG,
RED_BG,
GREEN_BG,
YELLOW_BG,
BLUE_BG,
MAGENTA_BG,
CYAN_BG,
LIGHT_GRAY_BG,
DEFAULT_BG,
DARK_GRAY_BG,
LIGHT_RED_BG,
LIGHT_GREEN_BG,
LIGHT_YELLOW_BG,
LIGHT_BLUE_BG,
LIGHT_MAGENTA_BG,
LIGHT_CYAN_BG,
WHITE_BG,
BOLD,
FAINT,
ITALICS,
UNDERLINE,
BLINK,
NEGATIVE,
CONCEAL,
STRIKETHROUGH

const BLACK_FG         = Crayon(foreground = :black         )
const RED_FG           = Crayon(foreground = :red           )
const GREEN_FG         = Crayon(foreground = :green         )
const YELLOW_FG        = Crayon(foreground = :yellow        )
const BLUE_FG          = Crayon(foreground = :blue          )
const MAGENTA_FG       = Crayon(foreground = :magenta       )
const CYAN_FG          = Crayon(foreground = :cyan          )
const LIGHT_GRAY_FG    = Crayon(foreground = :light_gray    )
const DEFAULT_FG       = Crayon(foreground = :default       )
const DARK_GRAY_FG     = Crayon(foreground = :dark_gray     )
const LIGHT_RED_FG     = Crayon(foreground = :light_red     )
const LIGHT_GREEN_FG   = Crayon(foreground = :light_green   )
const LIGHT_YELLOW_FG  = Crayon(foreground = :light_yellow  )
const LIGHT_BLUE_FG    = Crayon(foreground = :light_blue    )
const LIGHT_MAGENTA_FG = Crayon(foreground = :light_magenta )
const LIGHT_CYAN_FG    = Crayon(foreground = :light_cyan    )
const WHITE_FG         = Crayon(foreground = :white         )

const BLACK_BG         = Crayon(background = :black         )
const RED_BG           = Crayon(background = :red           )
const GREEN_BG         = Crayon(background = :green         )
const YELLOW_BG        = Crayon(background = :yellow        )
const BLUE_BG          = Crayon(background = :blue          )
const MAGENTA_BG       = Crayon(background = :magenta       )
const CYAN_BG          = Crayon(background = :cyan          )
const LIGHT_GRAY_BG    = Crayon(background = :light_gray    )
const DEFAULT_BG       = Crayon(background = :default       )
const DARK_GRAY_BG     = Crayon(background = :dark_gray     )
const LIGHT_RED_BG     = Crayon(background = :light_red     )
const LIGHT_GREEN_BG   = Crayon(background = :light_green   )
const LIGHT_YELLOW_BG  = Crayon(background = :light_yellow  )
const LIGHT_BLUE_BG    = Crayon(background = :light_blue    )
const LIGHT_MAGENTA_BG = Crayon(background = :light_magenta )
const LIGHT_CYAN_BG    = Crayon(background = :light_cyan    )
const WHITE_BG         = Crayon(background = :white         )

const BOLD             = Crayon(bold          = true)
const FAINT            = Crayon(faint         = true)
const ITALICS          = Crayon(italics       = true)
const UNDERLINE        = Crayon(underline     = true)
const BLINK            = Crayon(blink         = true)
const NEGATIVE         = Crayon(negative      = true)
const CONCEAL          = Crayon(conceal       = true)
const STRIKETHROUGH    = Crayon(strikethrough = true)

end
