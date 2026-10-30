-- Ported from FrancescoDeSimone/kickstart.nvim's lua/keymap.lua -- the
-- "recomendado" + "opcional" subset only (no tabs/sessions/quickfix→
-- diagnostics; those were left out on purpose, see the nvim config chat).

-- Basics
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear highlight search" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("t", "<C-w>", "<C-\\><C-n><C-w>", { desc = "Window commands from terminal" })
vim.keymap.set("t", "<C-w><C-k>", "<C-\\><C-n><C-w><C-k>", { desc = "Terminal: focus upper window" })
vim.keymap.set("t", "<C-w><C-j>", "<C-\\><C-n><C-w><C-j>", { desc = "Terminal: focus lower window" })
vim.keymap.set("t", "<C-w><Up>", "<C-\\><C-n><C-w><C-k>", { desc = "Terminal: focus upper window" })
vim.keymap.set("t", "<C-w><Down>", "<C-\\><C-n><C-w><C-j>", { desc = "Terminal: focus lower window" })
vim.keymap.set("n", "gp", "`[v`]", { desc = "Select last pasted text" })

-- Search / replace
vim.keymap.set("n", "<leader>rw", ":s/\\v(.{80})/\\1\\r/g<CR>", { desc = "Wrap line at 80 chars" })
vim.keymap.set("n", "<leader>sr", ":%s/<C-r><C-w>/<C-r><C-w>/gI<Left><Left><Left>", { desc = "Replace word under cursor" })
vim.keymap.set("x", "g/", "<Esc>/\\%V", { desc = "Search inside visual selection" })
vim.keymap.set({ "n", "x" }, "<leader>sR", function()
  require("grug-far").open({ visualSelectionUsage = "operate-within-range" })
end, { desc = "Search/Replace (Grug-far)" })

-- Shift+arrows select/extend (works in Normal, Visual, and Insert)
vim.keymap.set("n", "<S-Up>", "v<Up>", { desc = "Select Up" })
vim.keymap.set("n", "<S-Down>", "v<Down>", { desc = "Select Down" })
vim.keymap.set("n", "<S-Left>", "v<Left>", { desc = "Select Left" })
vim.keymap.set("n", "<S-Right>", "v<Right>", { desc = "Select Right" })
vim.keymap.set("v", "<S-Up>", "<Up>", { desc = "Extend Up" })
vim.keymap.set("v", "<S-Down>", "<Down>", { desc = "Extend Down" })
vim.keymap.set("v", "<S-Left>", "<Left>", { desc = "Extend Left" })
vim.keymap.set("v", "<S-Right>", "<Right>", { desc = "Extend Right" })
vim.keymap.set("i", "<S-Up>", "<Esc>v<Up>", { desc = "Select Up" })
vim.keymap.set("i", "<S-Down>", "<Esc>v<Down>", { desc = "Select Down" })
vim.keymap.set("i", "<S-Left>", "<Esc>v<Left>", { desc = "Select Left" })
vim.keymap.set("i", "<S-Right>", "<Esc>v<Right>", { desc = "Select Right" })
vim.keymap.set("v", "<", "<gv", { desc = "Indent Left (Keep Selection)" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent Right (Keep Selection)" })

-- Quickfix / location list navigation
vim.keymap.set("n", "[q", ":cprev<CR>", { desc = "Previous quickfix" })
vim.keymap.set("n", "]q", ":cnext<CR>", { desc = "Next quickfix" })
vim.keymap.set("n", "[l", ":lprev<CR>", { desc = "Previous location" })
vim.keymap.set("n", "]l", ":lnext<CR>", { desc = "Next location" })

-- Folds
vim.keymap.set("n", "<leader>fo", "za", { desc = "Toggle Fold" })
vim.keymap.set("n", "<leader>fO", "zA", { desc = "Toggle All Folds" })
vim.keymap.set("n", "<leader>fr", "zR", { desc = "Open All Folds" })
vim.keymap.set("n", "<leader>fm", "zM", { desc = "Close All Folds" })

-- Neovim 0.12 built-in optional plugins (confirmed available on 0.12.5)
vim.keymap.set("n", "<leader>U", "<cmd>Undotree<CR>", { desc = "Toggle Undotree" })
vim.keymap.set("n", "<leader>uH", "<cmd>TOhtml<CR>", { desc = "Export buffer to HTML" })
vim.keymap.set("n", "<leader>td", "<cmd>DiffTool<CR>", { desc = "Diff Tool" })

-- LSP
vim.keymap.set("n", "<leader>tl", function()
  vim.lsp.codelens.refresh({ bufnr = 0 })
end, { desc = "Refresh Codelenses" })
