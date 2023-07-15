vim.api.nvim_create_autocmd('FocusGained', {
    callback = function(_) vim.api.nvim_exec_autocmds('User', { pattern = 'NvimStartupDone' }) end,
    once = true,
})
