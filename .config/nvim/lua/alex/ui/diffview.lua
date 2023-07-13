require('diffview').setup {
    enhanced_diff_hl = true,
    hooks = {
        view_opened = function() require('diffview.actions').toggle_files() end,
    },
}
