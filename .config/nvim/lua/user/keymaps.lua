local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

-- Space to leader
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Center search results
keymap("n", "n", "nzz", opts)
keymap("n", "N", "Nzz", opts)

-- Add undo breakpoints
keymap("i", ",", ",<c-g>u", opts)
keymap("i", ".", ".<c-g>u", opts)
keymap("i", "!", "!<c-g>u", opts)
keymap("i", "?", "?<c-g>u", opts)

-- Netrw shortcuts
keymap("n", "<Leader>nf", ":Explore<CR>", opts)
keymap("n", "<Leader>nv", ":Vexplore<CR>", opts)
keymap("n", "<Leader>nh", ":Hexplore<CR>", opts)
keymap("n", "<Leader>nl", ":Lexplore<CR>", opts)
keymap("n", "<Leader>ns", ":Sexplore<CR>", opts)
vim.g.netrw_bufsettings = "noma"

-- Ranger-like tab spawn
keymap("n", "gn", ":tabnew<CR>", opts)

-- fzf keymaps
keymap("n", "<Leader>b", "<cmd>lua require('fzf-lua').buffers()<CR>", opts)
keymap("n", "<Leader>o", "<cmd>lua require('fzf-lua').files()<CR>", opts)
keymap("n", "<Leader>hf", "<cmd>lua require('fzf-lua').oldfiles()<CR>", opts)
keymap("n", "<Leader>gc", "<cmd>lua require('fzf-lua').git_bcommits()<CR>", opts)
keymap("n", "<Leader>gl", "<cmd>lua require('fzf-lua').git_commits()<CR>", opts)
keymap("n", "<Leader>gd", "<cmd>lua require('fzf-lua').git_status()<CR>", opts)
keymap("n", "<Leader>gb", "<cmd>lua require('fzf-lua').git_branches()<CR>", opts)
keymap("n", "<Leader>a", "<cmd>lua require('fzf-lua').live_grep()<CR>", opts)
keymap("n", "<Leader>t", "<cmd>lua require('fzf-lua').tags_grep_cword()<CR>", opts)
keymap("n", "gr", "<cmd>lua require('fzf-lua').lsp_references()<CR>", opts)
keymap("n", "gd", "<cmd>lua require('fzf-lua').lsp_definitions()<CR>", opts)
keymap("n", "gD", "<cmd>lua require('fzf-lua').lsp_declarations()<CR>", opts)
keymap("n", "gi", "<cmd>lua require('fzf-lua').lsp_implementations()<CR>", opts)
keymap("n", "<Leader>s", "<cmd>lua require('fzf-lua').lsp_document_symbols()<CR>", opts)
keymap("n", "<Leader>ca", "<cmd>lua require('fzf-lua').lsp_code_actions()<CR>", opts)
keymap("n", "<Leader>c", "<cmd>lua require('fzf-lua').commands()<CR>", opts)
keymap("n", "<Leader>hc", "<cmd>lua require('fzf-lua').command_history()<CR>", opts)
keymap("n", "<Leader>hs", "<cmd>lua require('fzf-lua').search_history()<CR>", opts)
keymap("n", "<Leader>m", "<cmd>lua require('fzf-lua').marks()<CR>", opts)
keymap("n", "<Leader>km", "<cmd>lua require('fzf-lua').keymaps()<CR>", opts)
keymap("n", "<Leader>rtfm", "<cmd>lua require('fzf-lua').man_pages()<CR>", opts)
keymap("n", "<Leader>help", "<cmd>lua require('fzf-lua').help_tags()<CR>", opts)
keymap("n", "<Leader>dc", "<cmd>lua require('fzf-lua').dap_commands()<CR>", opts)
keymap("n", "<Leader>dl", "<cmd>lua require('fzf-lua').dap_configurations()<CR>", opts)
keymap("n", "<Leader>db", "<cmd>lua require('fzf-lua').dap_breakpoints()<CR>", opts)
keymap("n", "<Leader>dv", "<cmd>lua require('fzf-lua').dap_variables()<CR>", opts)
keymap("n", "<Leader>df", "<cmd>lua require('fzf-lua').dap_frames()<CR>", opts)
-- keymap("n", "<Leader>color", "<cmd>lua require('fzf-lua').colorschemes()<CR>", opts)
-- keymap("n", "<Leader>highlights", "<cmd>lua require('fzf-lua').highlights()<CR>", opts)
-- keymap("n", "<Leader>dt", "<cmd>lua require('fzf-lua').filetypes()<CR>", opts)
-- keymap("n", "<Leader>m", "<cmd>lua require('fzf-lua').menus()<CR>", opts)
-- keymap("n", "<Leader>j", "<cmd>lua require('fzf-lua').jumps()<CR>", opts)
-- keymap("n", "<Leader>ch", "<cmd>lua require('fzf-lua').changes()<CR>", opts)
-- keymap("n", "<Leader>r", "<cmd>lua require('fzf-lua').registers()<CR>", opts)
-- keymap("n", "<Leader>st", "<cmd>lua require('fzf-lua').tagstack()<CR>", opts)
-- keymap("n", "<Leader>gs", "<cmd>lua require('fzf-lua').git_stash()<CR>", opts)
-- keymap("n", "<Leader>ac", "<cmd>lua require('fzf-lua').live_grep_resume()<CR>", opts)
-- keymap("n", "<Leader>ws", "<cmd>lua require('fzf-lua').lsp_workspace_symbols()<CR>", opts)
-- keymap("n", "gt", "<cmd>lua require('fzf-lua').lsp_typedefs()<CR>", opts)
-- keymap("n", "<Leader>bt", "<cmd>lua require('fzf-lua').btags()<CR>", opts)
-- keymap("n", "<Leader>gt", "<cmd>lua require('fzf-lua').tags_grep()<CR>", opts)
-- keymap("n", "<Leader>ht", "<cmd>lua require('fzf-lua').tags_grep_cword()<CR>", opts)
-- keymap("n", "<Leader>vt", "<cmd>lua require('fzf-lua').tags_grep_visual()<CR>", opts)
-- keymap("n", "<Leader>lt", "<cmd>lua require('fzf-lua').tags_live_grep()<CR>", opts)
-- keymap("n", "<Leader>ic", "<cmd>lua require('fzf-lua').lsp_incoming_calls()<CR>", opts)
-- keymap("n", "<Leader>oc", "<cmd>lua require('fzf-lua').lsp_outgoing_calls()<CR>", opts)
-- keymap("n", "<Leader>dd", "<cmd>lua require('fzf-lua').lsp_document_diagnostics()<CR>", opts)
-- keymap("n", "<Leader>dw", "<cmd>lua require('fzf-lua').lsp_workspace_diagnostics()<CR>", opts)

-- lsp keymaps
keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
keymap("n", "<Leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
keymap("n", "<Leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
keymap("n", "<Leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
keymap("n", "<Leader>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
-- keymap("n", "<Leader>d", "<cmd>lua vim.diagnostic.setqflist()<CR>", opts)
-- keymap("n", "<Leader>s", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", opts)
-- keymap("n", "<Leader>ws", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>", opts)
-- keymap("n", "<Leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
-- keymap("n", "<Leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
-- keymap("n", "<Leader>wl", "<cmd>lua vim.lsp.buf.list_workspace_folders()))<CR>", opts)
keymap("n", "<Leader>gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
-- keymap("n", "<Leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
-- keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
-- keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
-- keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
-- keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)

-- Hop keymaps
keymap("n", "<Leader>hw", "<cmd>lua require'hop'.hint_char1()<cr>", opts)
keymap("n", "<Leader>j", "<cmd>lua require'hop'.hint_words()<cr>", opts)

-- Spectre keymaps
keymap("n", "<Leader>rg", "<cmd>lua require('spectre').open()<cr>", opts)
keymap("n", "<Leader>rl", "<cmd>lua require('spectre').open_file_search()<cr>", opts)

-- gitsigns
keymap("n", "<Leader>ghs", "<cmd>Gitsigns preview_hunk<cr>", opts)
keymap("n", "<Leader>ghr", "<cmd>Gitsigns preview_hunk<cr>", opts)
keymap("n", "<Leader>ghb", "<cmd>Gitsigns blame_line<cr>", opts)

keymap("n", "<Leader>kl", "<cmd>lua vim.lsp.stop_client(vim.lsp.get_active_clients())<CR>", opts)
