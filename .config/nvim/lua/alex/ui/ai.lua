require 'chatgpt' .setup {
    chat = {
        welcome_message = ' 󱚝  I am coming for your career...',
        loading_text = "󱚟 ",
        question_sign = "󰵅 ",
        -- question_sign = " ",
        answer_sign = " 󰚩 ",
        keymaps = {
            close = { "<C-q>" },
            yank_last = "<C-y>",
            yank_last_code = "<C-k>",
            scroll_up = "<C-u>",
            scroll_down = "<C-d>",
            toggle_settings = "<C-s>",
            new_session = "<C-n>",
            cycle_windows = "<Tab>",
            select_session = "<Space>",
            rename_session = "<C-r>",
            delete_session = "<C-d>",
        },
    },
    popup_input = {
        prompt = "    "
    }
}
