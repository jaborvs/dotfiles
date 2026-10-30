return {
  "nvim-mini/mini.nvim",
  config = function()
    require("mini.ai").setup({ n_lines = 500 })
    require("mini.surround").setup()
    require("mini.trailspace").setup()
    require("mini.move").setup({
      mappings = {
        left = "<M-Left>",
        right = "<M-Right>",
        down = "<M-Down>",
        up = "<M-Up>",
        line_left = "<M-Left>",
        line_right = "<M-Right>",
        line_down = "<M-Down>",
        line_up = "<M-Up>",
      },
    })
    require("mini.align").setup()
    require("mini.bracketed").setup()
  end,
}
