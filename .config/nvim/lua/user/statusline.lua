-- @Based on: https://nuxsh.is-a.dev/blog/custom-nvim-statusline.html

local function filepath()
    local fpath = vim.fn.fnamemodify(vim.fn.expand "%", ":~:.:h")
    if fpath == "" or fpath == "." then
        return " "
    end

    return string.format(" %%<%s/", fpath)
end

local function filename()
    local fname = vim.fn.expand "%:t"
    if fname == "" then
        return ""
    end
    return fname .. " "
end

local function lsp()
    local count = {}
    local levels = {
        errors = "Error",
        warnings = "Warn",
        info = "Info",
        hints = "Hint",
    }

    for k, level in pairs(levels) do
        count[k] = vim.tbl_count(vim.diagnostic.get(0, { severity = level }))
    end

    local errors = ""
    local warnings = ""
    local hints = ""
    local info = ""

    if count["errors"] ~= 0 then
        errors = " %#LspDiagnosticsSignError# " .. count["errors"]
    end
    if count["warnings"] ~= 0 then
        warnings = " %#LspDiagnosticsSignWarning# " .. count["warnings"]
    end
    if count["hints"] ~= 0 then
        hints = " %#LspDiagnosticsSignHint# " .. count["hints"]
    end
    if count["info"] ~= 0 then
        info = " %#LspDiagnosticsSignInformation# " .. count["info"]
    end

    return errors .. warnings .. hints .. info .. "%#Normal#"
end

local function filetype()
    return string.format(" %s ", vim.bo.filetype):upper()
end

local function lineinfo()
    if vim.bo.filetype == "alpha" then
        return ""
    end
    return " %P %l:%c "
end

vim.cmd [[hi HighlightGitAdd guifg=#a6e22e guibg=#2E323C gui=none ctermfg=grey ctermbg=black cterm=none]]
vim.cmd [[hi HighlightGitRemove guifg=#e95678 guibg=#2E323C gui=none ctermfg=grey ctermbg=black cterm=none]]
vim.cmd [[hi HighlightGitChange guifg=#66d9ef guibg=#2E323C gui=none ctermfg=grey ctermbg=black cterm=none]]

local function vcs()
    local git_info = vim.b.gitsigns_status_dict
    if not git_info or git_info.head == "" then
        return ""
    end
    local added = git_info.added and ("%#HighlightGitAdd#+" .. git_info.added .. " ") or ""
    local changed = git_info.changed and ("%#HighlightGitChange#~" .. git_info.changed .. " ") or ""
    local removed = git_info.removed and ("%#HighlightGitRemove#-" .. git_info.removed .. " ") or ""
    if git_info.added == 0 then
        added = ""
    end
    if git_info.changed == 0 then
        changed = ""
    end
    if git_info.removed == 0 then
        removed = ""
    end

    return table.concat {
        " ",
        added,
        changed,
        removed,
        " ",
        "%#HighlightGitAdd# ",
        git_info.head,
        "%#StatusLine#",
    }
end

local function lsp_progress()
    local lsp = vim.lsp.util.get_progress_messages()[1]
    if lsp then
        local name = lsp.name or ""
        local msg = lsp.message or ""
        local percentage = lsp.percentage or 0
        local title = lsp.title or ""
        return string.format(" %%<%s: %s %s (%s%%%%) ", name, title, msg, percentage)
    end

    return ""
end

Statusline = {}

Statusline.active = function()
    return table.concat {
        -- "%#Statusline#",
        -- update_mode_colors(),
        -- mode(),
        -- "%#Normal# ",
        -- filepath(),
        filename(),
        -- "%#Normal#",
        "%=%#StatusLineExtra#",
        -- "%#Normal#",
        lsp_progress(),
        vcs(),
        lsp(),
        -- filetype(),
        -- lineinfo(),
    }
end

function Statusline.inactive()
    return " %F"
end

function Statusline.short()
    return "%#StatusLineNC#   NvimTree"
end

vim.api.nvim_exec([[
    augroup Statusline
    au!
    au WinEnter,BufEnter * setlocal statusline=%!v:lua.Statusline.active()
    au WinLeave,BufLeave * setlocal statusline=%!v:lua.Statusline.inactive()
    au WinEnter,BufEnter,FileType NvimTree setlocal statusline=%!v:lua.Statusline.short()
    augroup END
]], false)
