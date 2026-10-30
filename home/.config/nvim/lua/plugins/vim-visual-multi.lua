return {
  "mg979/vim-visual-multi",
  branch = "master",
  event = "VeryLazy",
  init = function()
    vim.g.VM_maps = {
      ["Find Under"] = "<C-n>",
      ["Find Subword Under"] = "<C-n>",
      -- Shift+arrows are owned by lua/keymaps.lua (plain visual selection);
      -- VM would otherwise grab them and enter its own extend mode.
      ["Select l"] = "",
      ["Select h"] = "",
    }
  end,
}
