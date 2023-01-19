-- Cache exe locations based on the dir.
local M = {}

M._cache_location = os.getenv('HOME') .. "/.config/nvim/lua/alex/lang/debugger/.cache.json"

function M._get_cache_file(desc)
    local cache_file = io.open(M._cache_location, desc)
    if cache_file == nil then
        vim.notify("Could not open '.cache.json'.", "error", {
            title = "Debugger Cache"
        })
        return nil
    end
    return cache_file
end

function M._get_cache_tab()
    local cache_file = M._get_cache_file("rb")
    if cache_file == nil then
        return {}
    end
    local file_string = cache_file:read("a")
    cache_file:close()
    if file_string == nil or file_string:len() == 0 then
        return {}
    end
    return require('cjson').decode(file_string)
end

function M.check_exe_cache(path)
    local json_tab = M._get_cache_tab()
    if json_tab[path] ~= nil then
        return json_tab[path]
    end
    return path
end

function M.update_exe_cache(path, exe_path)
    local json_tab = M._get_cache_tab()
    local cache_file = M._get_cache_file("w")
    if cache_file == nil then return end
    json_tab[path] = exe_path
    -- Write to the file.
    local json_string = require('cjson').encode(json_tab)
    cache_file:write(json_string)
    cache_file:close()
end

return M
