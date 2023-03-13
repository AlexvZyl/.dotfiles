vim.wo.statuscolumn = " "

vim.api.nvim_create_autocmd( { "BufEnter" }, { pattern = "*", command = "NvimTreeRefresh" })
