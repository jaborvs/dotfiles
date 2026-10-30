-- Only the two lightweight git extras -- git-conflict (resolve merge
-- conflicts visually) and diffview (diff/history panel). Deliberately
-- skipping neogit: gitsigns already covers day-to-day hunk staging, and a
-- full Magit-style status UI is IDE territory, not "code editor".
return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
      { "<leader>ghf", "<cmd>DiffviewFileHistory %<cr>", desc = "File History (Current)" },
      { "<leader>ghF", "<cmd>DiffviewFileHistory<cr>", desc = "File History (All)" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        merge_tool = {
          layout = "diff3_mixed",
          disable_diagnostics = true,
        },
      },
    },
  },
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    event = "BufReadPre",
    config = true,
    opts = {
      default_mappings = true, -- co, ct, cb, c0
    },
  },
}
