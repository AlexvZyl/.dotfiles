require('indent_blankline').setup {
    show_end_of_line = true,
    show_current_context = true,
    show_current_context_start = false,
    filetype_exclude = { 'NvimTree', 'startify', 'dashboard', 'help', 'markdown' },
    use_treesitter = false,
    use_treesitter_scope = false,
    context_char = '│',
    char = '┆',
}
