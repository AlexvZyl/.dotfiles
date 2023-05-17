require('copilot').setup {
    panel = { enabled = false },
    suggestion = {
        enabled = true,
        debounce = 75,
        keymap = { accept = '<C-\\>', dismiss = 'C-d' },
    },
    server_opts_overrides = {
        settings = {
            advanced = {
                listCount = 1,
                inlineSuggestCount = 1,
            },
        },
    },
}
