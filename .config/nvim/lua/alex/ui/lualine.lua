-- Using Lualine as the statusline.

-- Show git status.
local function diff_source()
    local gitsigns = vim.b.gitsigns_status_dict
    if gitsigns then
        return {
          added = gitsigns.added,
          modified = gitsigns.changed,
          removed = gitsigns.removed
        }
    end
end

-- Get the current buffer's filetype.
local function get_current_filetype()
    return vim.api.nvim_buf_get_option(0, 'filetype')
end

-- Get the current buffer's type.
local function get_current_buftype()
    return vim.api.nvim_buf_get_option(0, 'buftype')
end

-- Get the buffer's filename.
local function get_current_filename()
    local bufname = vim.api.nvim_buf_get_name(0)
    return bufname ~= '' and vim.fn.fnamemodify(bufname, ':t') or '[No Name]'
end

-- Gets the current buffer's filename with the filetype icon supplied
-- by devicons.
local M = require('lualine.components.filetype'):extend()
Icon_hl_cache = {}
local lualine_require = require('lualine_require')
local modules = lualine_require.lazy_require {
  highlight = 'lualine.highlight',
  utils = 'lualine.utils.utils',
}

-- Return the current buffer's filetype icon with highlighting.
function M:get_current_filetype_icon()

    -- Get setup.
    local icon, icon_highlight_group
    local _, devicons = pcall(require, 'nvim-web-devicons')
    local f_name, f_extension = vim.fn.expand('%:t'), vim.fn.expand('%:e')
    f_extension = f_extension ~= '' and f_extension or vim.bo.filetype
    icon, icon_highlight_group = devicons.get_icon(f_name, f_extension)

    -- Fallback settings.
    if icon == nil and icon_highlight_group == nil then
      icon = ''
      icon_highlight_group = 'DevIconDefault'
    end

    -- Set colors.
    local highlight_color = modules.utils.extract_highlight_colors(icon_highlight_group, 'fg')
    if highlight_color then
        local default_highlight = self:get_default_hl()
        local icon_highlight = Icon_hl_cache[highlight_color]
        if not icon_highlight or not modules.highlight.highlight_exists(icon_highlight.name .. '_normal') then
            icon_highlight = self:create_hl({ fg = highlight_color }, icon_highlight_group)
            Icon_hl_cache[highlight_color] = icon_highlight
        end
        icon = self:format_hl(icon_highlight) .. icon .. default_highlight
    end

    -- Return the formatted string.
    return icon

end

-- Return the current buffer's filename with the filetype icon.
function M:get_current_filename_with_icon()

    -- Get icon and filename.
    local icon = M.get_current_filetype_icon(self)
    local f_name = get_current_filename()

    -- Add readonly icon.
    local readonly = vim.api.nvim_buf_get_option(0, 'readonly')
    local modifiable = vim.api.nvim_buf_get_option(0, 'modifiable')
    local nofile = get_current_buftype() == 'nofile'
    if readonly or nofile or not modifiable then
        f_name = f_name .. ' '
    end

    -- Return the formatted string.
    return icon .. ' ' .. f_name .. ' '

end

-- Get the lsp of the current buffer, when using native lsp.
local function get_native_lsp()
        local buf_ft = get_current_filetype()
    local clients = vim.lsp.get_active_clients()
    if next(clients) == nil then
      return 'None'
    end
    for _, client in ipairs(clients) do
      local filetypes = client.config.filetypes
      if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
        return client.name
      end
    end
    return 'None'
end

-- Get the status of the compiler, if applicable.
local function get_compiler_status()
    local filetype = get_current_filetype()
    if filetype == 'tex' then
        return ''
    end
    return ''
end

-- Display the difference in commits between local and head.
local Job = require 'plenary.job'
local function get_git_compare()

    -- Get the path of the current directory.
    local curr_dir = vim.api.nvim_buf_get_name(0):match("(.*"..'/'..")")

    -- Run job to get git.
    local result = Job:new({
      command = 'git',
      cwd = curr_dir,
      args = { 'rev-list', '--left-right', '--count', 'HEAD...@{upstream}' },
    }):sync(100)[1]

    -- Process the result.
    if type(result) ~= 'string' then return '' end
    local ok, ahead, behind = pcall(string.match, result, "(%d+)%s*(%d+)")
    if not ok then return '' end

    -- No file, so no git.
    if get_current_buftype() == 'nofile' then
        return ''
    end

    -- Format for lualine.
    return ' '.. behind .. '  ' .. ahead

end

-- Required to properly set the colors.
local custom_nord = require 'alex.theme.utils'.get_nord_lualine_theme()
-- Get the palettes.
local np = require 'alex.theme.utils'.get_nord_palette()
local nf = require 'alex.theme.utils'.get_nordfox_palette()

require 'lualine'.setup {
    sections = {
        lualine_a = {
            {
                'mode',
                icon = { ' ' },
            },
        },
        lualine_b = {
            {
                M.get_current_filename_with_icon
            },
        },
        lualine_c = {
            {
                'branch',
                icon = {
                    '',
                    color = { fg = nf.orange.bright, gui = 'bold' },
                },
                separator = ' ',
            },
            {
                get_git_compare,
                separator = ' ',
                icon = {
                    ' ',
                    color = { fg = nf.orange.bright, gui = 'bold' },
                }
            },
            {
                'diff',
                colored = true,
                source = diff_source,
                symbols = {
                    added = ' ',
                    modified = ' ',
                    removed = ' '
                },
                diff_color = {
                    added = { fg = nf.green.base, gui = 'bold' },
                    modified = { fg = np.blue1, gui = 'bold' },
                    removed = { fg = nf.red.bright, gui = 'bold' },
                }
                -- icon = {
                    -- ' ',
                    -- color = { fg = get_color('Orange', 'fg') },
                -- }
            },
        },
        lualine_x = {
            {
                'diagnostics',
                sources = { 'nvim_diagnostic' },
                separator = '',
                symbols = {
                    error = ' ',
                    warn = ' ',
                    info = ' ',
                    hint = ' ',
                },
                diagnostics_color = {
                    error = { fg=nf.red.bright, gui='bold'   },
                    warn =  { fg=nf.yellow.base, gui='bold' },
                    info =  { fg=nf.blue.bright, gui='bold'   },
                    hint =  { fg=nf.green.bright, gui='bold'  },
                },
                colored = true,
            },
        },
        lualine_y = {
            {
               get_compiler_status,
                icon = {
                    ' ,',
                    align = 'left',
                    color = {
                        fg = nf.orange.bright,
                        gui = 'bold'
                    }
                },
                separator = ''
            },
            {
                get_native_lsp,
                icon = {
                    '  ',
                    align = 'left',
                    color = {
                        fg = nf.orange.bright,
                        gui = 'bold'
                    }
                }
            }, 
        },
        lualine_z = {
            {
                'location',
                icon = {
                    '',
                    align = 'left',
                    color = { fg = np.black },
                }
            },
            {
                'progress',
                icon = {
                    '',
                    align = 'left',
                    color = { fg = np.black },
                }
            }
        },
    },
    options = {
        disabled_filetypes = { "dashboard" },
        globalstatus = true,
        section_separators = { left = ' ', right = ' ' },
        component_separators = { left = '', right = ''},
        theme = custom_nord,
    },
    extensions = {
        "toggleterm",
        "nvim-tree"
    }
}
