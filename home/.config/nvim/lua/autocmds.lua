-- Ported from FrancescoDeSimone/kickstart.nvim's lua/autocommand.lua -- the
-- subset with no dependency on plugins/features we didn't install
-- (leetcode.nvim, :mksession keymaps, 0.12 LSP semantic-highlight groups
-- tuned to his own theme overrides).

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

local misc_group = vim.api.nvim_create_augroup("kickstart-misc", { clear = true })

vim.api.nvim_create_autocmd("VimResized", {
  group = misc_group,
  callback = function()
    vim.cmd("wincmd =")
  end,
})

-- Restore cursor to last known position when reopening a file
vim.api.nvim_create_autocmd("BufReadPost", {
  group = misc_group,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- FileType-specific settings
local ft_group = vim.api.nvim_create_augroup("kickstart-filetype", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = ft_group,
  pattern = "gitcommit",
  callback = function()
    vim.opt_local.textwidth = 72
    vim.opt_local.spell = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = ft_group,
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.conceallevel = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = ft_group,
  pattern = "help",
  callback = function()
    vim.opt_local.list = false
    vim.opt_local.spell = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true, desc = "Close help" })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = ft_group,
  pattern = "qf",
  callback = function()
    vim.opt_local.spell = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true, desc = "Close quickfix" })
  end,
})
