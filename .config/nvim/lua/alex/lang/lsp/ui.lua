--------------
-- LSP Saga --
--------------

local ui = {
    theme = 'round',
    border = 'rounded',
    winblend = 5,
    title = false,
    diagnostic = '  ',
    kind = {}
}

local lightbulb = {
    enable = false
}

local definition = {
    edit = '<C-e>',
    vsplit = '<C-v>',
    split = '<C-h>',
    quit = 'q',
}

local winbar = {
    enable = false,
    folder_level = 1,
    show_file = true,
    separator = '  '
}

local diagnostic = {
    show_code_action = false
}

require 'lspsaga' .setup {
    lightbulb = lightbulb,
    ui = ui,
    definition = definition,
    symbol_in_winbar = winbar,
    diagnostic = diagnostic
}

---------------------------
-- Trouble (diagnostics) --
---------------------------

require 'trouble'.setup {
    padding = true,
    height = 11,
    use_diagnostic_signs = false,
    position = 'bottom',
    signs = {
        -- error = " ",
        -- warning = " ",
        -- hint = " ",
        -- information = " ",
        -- other = " "
        error = ' ',
        warning = ' ',
        info = ' ',
        hint = '󱤅 ',
        other = '󰠠 ',
    },
    auto_preview = false
}

-- Make trouble update to the current buffer.
vim.cmd [[ autocmd BufEnter * TroubleRefresh ]]

------------
-- Fidget -- 
------------

-- require"fidget" .setup {
--     text = {
--         done= ' ',
--     },
--     window = {
--         relative = "editor",
--         blend = 100,
--     },
--     fmt = {
--     leftpad = true,           -- right-justify text in fidget box
--     stack_upwards = true,     -- list of tasks grows upwards
--     max_width = 0,            -- maximum width of the fidget box
--     fidget =                  -- function to format fidget title
--       function(fidget_name, spinner)
--         return string.format("%s %s", spinner, fidget_name)
--       end,
--     task =                    -- function to format each task line
--       function(task_name, message, percentage)
--         return string.format(
--           "%s%s [%s]",
--           message,
--           percentage and string.format(" (%s%%)", percentage) or "",
--           task_name
--         )
--       end,
--   },
-- }
