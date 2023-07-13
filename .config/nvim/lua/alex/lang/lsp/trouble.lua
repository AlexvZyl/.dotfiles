local u = require 'alex.utils'

require('trouble').setup {
    padding = true,
    height = 11,
    use_diagnostic_signs = false,
    position = 'bottom',
    signs = u.diagnostic_signs,
    auto_preview = false,
}

vim.cmd [[ autocmd BufEnter * TroubleRefresh ]]
