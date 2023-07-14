vim.api.nvim_create_autocmd('User', {
    callback = function(_) vim.api.nvim_exec_autocmds('User', { pattern = 'NvimStartupDone' }) end,
    pattern = { 'LazyVimStarted' },
    once = true,
})
