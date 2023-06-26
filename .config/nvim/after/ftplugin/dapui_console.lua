function Dap_repl()
    vim.cmd [[setlocal cursorlineopt=number]]
    vim.cmd [[echo "Hi There!"]]
    vim.cmd [[setlocal statuscolumn=\ ]]
end

vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter' }, {
    callback = Dap_repl,
    pattern = { 'dapui_console' },
})

Dap_repl()
