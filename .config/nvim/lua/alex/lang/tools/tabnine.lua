local p = require 'nordic.colors'

require('tabnine').setup({
  disable_auto_comment=true,
  accept_keymap= '<C-\\>',
  dismiss_keymap = '<C-d>',
  debounce_ms = 800,
  suggestion_color = {gui = p.gray1, cterm = 244},
  exclude_filetypes = { "TelescopePrompt" },
  log_file_path = nil, -- absolute path to Tabnine log file
})
