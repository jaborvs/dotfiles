-- Styling only (border, icons, layout) -- Francesco's `spec` table just
-- labels his own <leader> groups (Avante, Debug, Programming...) which don't
-- exist in this keymap, so it's dropped; which-key still auto-discovers and
-- displays every keymap that carries a `desc`.
return {
  "folke/which-key.nvim",
  event = "VimEnter",
  opts = {
    preset = "modern",
    delay = 0,
    icons = {
      mappings = vim.g.have_nerd_font,
      group = " ",
      separator = "󰜴 ",
      colors = true,
    },
    win = {
      border = "rounded",
      padding = { 1, 2 },
      title = true,
      title_pos = "center",
    },
    layout = {
      width = { min = 24, max = 42 },
      spacing = 2,
    },
  },
}
