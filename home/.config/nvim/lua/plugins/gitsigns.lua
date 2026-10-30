return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      add          = { text = "▎" },
      change       = { text = "▎" },
      delete       = { text = "_" },
      topdelete    = { text = "‾" },
      changedelete = { text = "~" },
      untracked    = { text = "▎" },
    },
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end

      -- Navigation
      map("n", "]c", function()
        if vim.wo.diff then return "]c" end
        vim.schedule(function() gs.next_hunk() end)
        return "<Ignore>"
      end, "Next hunk")

      map("n", "[c", function()
        if vim.wo.diff then return "[c" end
        vim.schedule(function() gs.prev_hunk() end)
        return "<Ignore>"
      end, "Prev hunk")

      -- Actions
      map("n", "<leader>hs", gs.stage_hunk,        "Stage hunk")
      map("n", "<leader>hr", gs.reset_hunk,        "Reset hunk")
      map("n", "<leader>hS", gs.stage_buffer,      "Stage buffer")
      map("n", "<leader>hu", gs.undo_stage_hunk,   "Undo stage hunk")
      map("n", "<leader>hR", gs.reset_buffer,      "Reset buffer")
      map("n", "<leader>hp", gs.preview_hunk,      "Preview hunk")
      map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
      map("n", "<leader>hd", gs.diffthis,          "Diff this")

      -- Toggle
      map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle line blame")
    end,
  },
}
