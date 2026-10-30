-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Force single-cell width for East-Asian-ambiguous-width characters (the
-- box-drawing glyphs used in fillchars below, e.g. ┳ ┻ ┣ ┫ ╋, are in that
-- Unicode category). Without this, a real TTY can lead Neovim to treat them
-- as double-width depending on terminal/locale negotiation, and `fillchars`
-- rejects any value wider than 1 cell with E474 -- invisible in --headless
-- testing since there's no terminal to negotiate with.
vim.opt.ambiwidth = "single"
-- Basic options
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

vim.opt.number = true
vim.opt.relativenumber = true
-- statuscolumn is now owned by Snacks' `statuscolumn` module (see
-- lua/plugins/snacks.lua); it replaces the hand-rolled relnum/lnum hybrid
-- that used to live here.

vim.opt.termguicolors = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = -1

-- Visual options ported from FrancescoDeSimone/kickstart.nvim's
-- lua/options.lua.
vim.opt.showmode = false
vim.opt.confirm = true
vim.opt.breakindent = true
vim.opt.cc = "80,120"
vim.opt.copyindent = true
vim.opt.cursorline = false
vim.opt.fillchars = {
  eob = " ", -- hide end-of-buffer filler lines (~)
  diff = "╱",
  fold = " ",
  foldinner = "│",
  horiz = "━",
  horizdown = "┳",
  horizup = "┻",
  msgsep = "‾",
  vert = "┃",
  verthoriz = "╋",
  vertleft = "┫",
  vertright = "┣",
}
vim.opt.foldcolumn = "1"
vim.opt.foldenable = true
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = -1
vim.opt.foldmethod = "expr"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split"
vim.opt.list = true
vim.opt.listchars = "tab:→ ,nbsp:␣,trail:•,extends:⟩,precedes:⟨"
vim.opt.modeline = true
vim.opt.modelines = 5
vim.opt.mouse = "a"
vim.opt.mousemodel = "extend"
vim.opt.preserveindent = true
vim.opt.pumheight = 10
vim.opt.redrawtime = 10000
vim.opt.report = 9001
vim.opt.scrolloff = 10
vim.opt.showbreak = "↪\\"
vim.opt.signcolumn = "yes:2"
vim.opt.spell = false
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.swapfile = false
vim.opt.synmaxcol = 0
vim.opt.timeoutlen = 100
vim.opt.undofile = true
vim.opt.updatetime = 100
vim.opt.wildignorecase = true
vim.opt.wrap = false
vim.opt.pumborder = "rounded"
vim.opt.winborder = "rounded"
vim.opt.messagesopt = "hit-enter,history:500,progress:c"
vim.opt.chistory = 10
vim.opt.lhistory = 10
vim.opt.maxsearchcount = 9999
vim.opt.pummaxwidth = 50
vim.opt.jumpoptions = "view"

-- System clipboard (requires wl-clipboard on Wayland)
vim.opt.clipboard = "unnamedplus"

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })

-- Load plugins
require("lazy").setup("plugins")

-- Extra keymaps/autocmds ported from FrancescoDeSimone/kickstart.nvim
require("keymaps")
require("autocmds")
