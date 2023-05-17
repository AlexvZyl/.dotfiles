require 'copilot' .setup {
    panel = { enabled = false },
    suggestion = {
        enabled = false,
        debounce = 200,
        keymap = { accept = '<C-\\>', dismiss = 'C-d' }
    }
}
