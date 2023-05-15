local lint = require 'lint'

lint.linters_by_ft = {
    latex = { 'chktex' },
    lua = { 'luacheck' }
}
