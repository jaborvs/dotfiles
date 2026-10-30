return {
  "epwalsh/obsidian.nvim",
  version = "*",
  ft = "markdown",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    workspaces = {
      { name = "work", path = "~/Documents/work/notes" },
    },
    completion = {
      nvim_cmp = false,
      blink = true,
      min_chars = 2,
    },
    templates = {
      folder = "Templates",
    },
    -- You already maintain frontmatter yourself via standardize_frontmatter.py;
    -- don't have the plugin inject/rewrite it too.
    disable_frontmatter = true,
    ui = { enable = false },
  },
  keys = {
    { "<leader>on", "<cmd>ObsidianNew<CR>", desc = "New Obsidian note" },
    { "<leader>os", "<cmd>ObsidianSearch<CR>", desc = "Search Obsidian notes" },
    { "<leader>ol", "<cmd>ObsidianFollowLink<CR>", desc = "Follow Obsidian [[link]]" },
    { "<leader>ob", "<cmd>ObsidianBacklinks<CR>", desc = "Show backlinks" },
    {
      "<leader>ox",
      function()
        require("obsidian").util.toggle_checkbox()
      end,
      mode = { "n", "v" },
      desc = "Toggle Obsidian checkbox",
    },
  },
}
