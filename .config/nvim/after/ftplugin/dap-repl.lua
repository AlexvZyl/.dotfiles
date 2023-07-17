vim.cmd "setlocal winbar=\\ REPL"
vim.opt.statuscolumn = "%= %{v:virtnum < 1 ? (v:lnum) : ''}%=%s "
