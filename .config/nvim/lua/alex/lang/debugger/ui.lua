local M = {}

function M.setup_dap_ui()
    require('dapui').setup {

        icons = {
            expanded = '',
            collapsed = '',
            current_frame = '',
        },
        mappings = {
            expand = {
                '<Tab>',
                '<2-LeftMouse>',
            },
            open = 'o',
            remove = 'd',
            edit = 'e',
            repl = 'r',
            toggle = 't',
        },
        -- Use this to override mappings for specific elements
        element_mappings = {
            -- Example:
            -- stacks = {
            --   open = "<CR>",
            --   expand = "o",
            -- }
        },
        -- Expand lines larger than the window
        -- Requires >= 0.7
        expand_lines = vim.fn.has 'nvim-0.7' == 1,
        -- Layouts define sections of the screen to place windows.
        -- The position can be "left", "right", "top" or "bottom".
        -- The size specifies the height/width depending on position. It can be an Int
        -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
        -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
        -- Elements are the elements shown in the layout (in order).
        -- Layouts are opened in order so that earlier layouts take priority in window sizing.
        layouts = {
            -- Vertical bar.
            {
                elements = {
                    {
                        id = 'stacks',
                        size = 0.40,
                    },
                    {
                        id = 'watches',
                        size = 0.5,
                    },
                    {
                        id = 'console',
                        size = 0.10,
                    },
                },
                size = 0.3,
                position = 'right',
            },
            -- Horizontal bar.
            {
                elements = {
                    'repl',
                },
                size = 0.2,
                position = 'bottom',
            },
        },
        controls = {
            enabled = true,
            element = 'console',
            icons = {
                pause = '',
                play = '',
                step_into = '',
                step_over = '',
                step_out = '',
                step_back = '',
                run_last = '',
                terminate = '',
            },
        },
        floating = {
            max_height = nil, -- These can be integers or a float between 0 and 1.
            max_width = nil, -- Floats will be treated as percentage of your screen.
            border = 'rounded',
            mappings = {
                close = { 'q', '<Esc>' },
            },
        },
        windows = {
            indent = 1,
        },
        render = {
            max_type_length = nil, -- Can be integer or nil.
            max_value_lines = 100, -- Can be integer or nil.
        },
    }
end

return M
