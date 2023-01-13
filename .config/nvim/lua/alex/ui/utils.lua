-- Was used with bufferline.  Keeping here for reference.

local M = {}

-- Common kill function for bdelete and bwipeout.
-- credits: based on bbye, nvim-bufdel and LunarVim.
---@param force? boolean defaults to false.
---@param ignore_list? table of buffer types to ignore.
function M.close_current_buffer_LV(force, ignore_list)

    -- Command used to kill the buffer.
    local kill_command = "bd"

    -- Default list of items to ignore.
    if not ignore_list then
        ignore_list = {
           'nvimtree',
           'nofile',
           'startify',
           'terminal'
        }
    end

    -- Required data.
    local bo = vim.bo
    local api = vim.api
    local fmt = string.format
    local fnamemodify = vim.fn.fnamemodify
    local bufnr = api.nvim_get_current_buf()
    local bufname = api.nvim_buf_get_name(bufnr)
    local buf_type = api.nvim_buf_get_option(0, 'buftype')

    -- Check if the current buffer should be ignored.
    for _, type in ipairs(ignore_list) do
        if type == buf_type then
            -- Do not delete.
            return
        end
    end

    -- Warn user if a modified buffer is about to be deleted.
    if not force then
        local warning
        if bo[bufnr].modified then
            warning = fmt([[(%s) has unsaved changes.]], fnamemodify(bufname, ":t"))
        elseif buf_type == "terminal" then
            warning = fmt([[Terminal %s will be killed.]], bufname)
        end
        if warning then
            vim.ui.input({
            prompt = string.format([[%s. Close it anyway? [y]es or [n]o (default: no): ]], warning),
            }, function(choice)
                if choice:match "ye?s?" then force = true end
            end)
            if not force then return end
        end
    end

    -- Get list of windows IDs with the buffer to close.
    local windows = vim.tbl_filter(function(win)
        return api.nvim_win_get_buf(win) == bufnr
    end, api.nvim_list_wins())

    -- No windows to close.
    if #windows == 0 then return end

    -- Create force command.
    if force then
        kill_command = kill_command .. "!"
    end

    -- Get list of active buffers
    local buffers = vim.tbl_filter(function(buf)
        return api.nvim_buf_is_valid(buf) and bo[buf].buflisted
    end, api.nvim_list_bufs())

    -- For more than one buffer, pick the previous buffer (wrapping around if necessary)
    if #buffers > 1 then
        for i, v in ipairs(buffers) do
            if v == bufnr then
                local prev_buf_idx = i == 1 and (#buffers - 1) or (i - 1)
                local prev_buffer = buffers[prev_buf_idx]
                for _, win in ipairs(windows) do
                    api.nvim_win_set_buf(win, prev_buffer)
                end
            end
        end
    end

    -- Check if buffer still exists, to ensure the target buffer wasn't killed
    -- due to options like bufhidden=wipe.
    if api.nvim_buf_is_valid(bufnr) and bo[bufnr].buflisted then
        vim.cmd(fmt("%s %d", kill_command, bufnr))
    end

    -- If there was only one buffer (which had to be the current one), vim will
    -- create a new buffer (and keep a window open) on :bd.

end

return  M
