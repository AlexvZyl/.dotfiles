-------------------
-- Lualine setup --
-------------------

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

-- Get the OS to display in Lualine.
-- Just gonna hard code Arch for now.
local function get_os()
    -- return '  '
    return 'Archlinux  '
    -- return '  '
    -- return 'Windows  '
    -- return '  '
    -- return 'Debian  '
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
    local ok, devicons = pcall(require, 'nvim-web-devicons')
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

-- Get the status of the native LSP attached to the current buffer.
-- This might not be the best way to get the status, but it works.
local function get_native_lsp_status()
    -- Get info.
    local clients = vim.lsp.get_active_clients()
    local current_lsp = get_native_lsp()
    -- No language server running.
    if current_lsp == 'None' then return '' end
    -- Check if the last received message is still running.
    for _, client in ipairs(clients) do
        if client.name == current_lsp then
            if next(client.messages.status) ~= nil then
                return client.messages.status
            end
        end
    end
    -- Everything is okay.
    return ''
end


-- Get the lsp of the current buffer, when using coc.
local function get_coc_lsp()
    local services = vim.fn.CocAction('services')
    local current_lang = get_current_filetype()
    for _, lsp in pairs(services) do
        for _, lang in pairs(lsp['languageIds']) do
            if lang == current_lang then
                return lsp['id']
            end
        end
    end
    return 'None'
end

-- Get the status of the LSP.
local function get_coc_lsp_status()
    local current_lsp = get_coc_lsp()
    if current_lsp == 'None' then
        return ''
    end
    local services = vim.fn.CocAction('services')
    for _, lsp in pairs(services) do
        if lsp['id'] == current_lsp then
            if lsp['state'] == 'running' then
                return ''
            else
                return lsp['state']
            end
        end
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
local get_color = require 'lualine.utils.utils'.extract_highlight_colors

require 'lualine'.setup {
    sections = {
        lualine_a = {
            {
                'mode',
                icon = { '' },
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
                    color = { fg = get_color('Orange', 'fg') },
                },
                separator = ' ',
            },
            {
                get_git_compare,
                separator = ' ',
                icon = {
                    ' ',
                    color = { fg = get_color('Orange', 'fg') },
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
                    error = { fg=get_color('Red', 'fg')    },
                    warn =  { fg=get_color('Yellow', 'fg') },
                    info =  { fg=get_color('Blue', 'fg')   },
                    hint =  { fg=get_color('Green', 'fg')  },
                },
                colored = true,
            },
        },
        lualine_y = {
            {
                get_native_lsp,
                icon = {
                    '  ',
                    align = 'left',
                    color = {
                        fg = get_color('Orange', 'fg'),
                        gui = 'bold'
                    }
                }
            },
            {
                get_native_lsp_status,
                icon = {
                    ' ',
                    align = 'left',
                    color = {
                        fg = get_color('Orange', 'fg'),
                        gui = 'bold'
                    }
                }
            }
        },
        lualine_z = {
            {
                'location',
                icon = {
                    '',
                    align = 'left',
                    color = { fg = get_color('Black', 'fg') },
                }
            },
            {
                'progress',
                icon = {
                    '',
                    align = 'left',
                    color = { fg = get_color('Black', 'fg') },
                }
            }
        },
    },
    options = {
        disabled_filetypes = { "startify" },
        globalstatus = true,
        section_separators = { left =' ', right = ' ' },
        component_separators = { left = '', right = ''},
    },
    extensions = {
        "toggleterm",
        "nvim-tree"
    }
}
