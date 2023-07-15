local U = require 'alex.utils'

require('mason').setup {
    ui = { border = U.border_chars_outer_thin },
}

local registry = require 'mason-registry'

local packages = {
    'rust-analyzer',
    'lua-language-server',
    'stylua',
    'luacheck',
    'julia-lsp',
    'bash-language-server',
    'pyright',
    'texlab',
    'cmake-language-server',
    'json-lsp',
    'yaml-language-server',
}

registry.refresh(function()
    for _, pkg_name in ipairs(packages) do
        local pkg = registry.get_package(pkg_name)
        if not pkg:is_installed() then pkg:install() end
    end
end)
