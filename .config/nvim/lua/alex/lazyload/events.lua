vim.api.nvim_create_autocmd('User', {
    callback = function(_) vim.api.nvim_exec_autocmds('User', { pattern = 'NvimStartupDone' }) end,
    pattern = { 'LazyVimStarted' },
    once = true,
})

local function delayed_start_event()
    vim.uv.sleep(5000)
    vim.api.nvim_exec_autocmds('User', { pattern = 'NvimStartupDone' })
    return true
end

-- vim.schedule_wrap(delayed_start_event)
