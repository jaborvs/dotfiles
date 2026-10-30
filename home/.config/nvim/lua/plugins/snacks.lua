return {
  -- File explorer sidebar, matching FrancescoDeSimone/kickstart.nvim's
  -- Snacks.explorer() setup (replaces neo-tree.nvim).
  "nvim-tree/nvim-web-devicons",

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      terminal = {
        win = {
          position = "bottom",
          height = 0.3,
        },
      },
      picker = {
        enabled = true,
        sources = {
          explorer = {
            regex_parents = true,
          },
        },
      },
      explorer = { enabled = true },
      indent = { enabled = true, animate = { enabled = false } },
      input = { enabled = true },
      scope = { enabled = true },
      words = { enabled = true },
      notifier = {
        enabled = true,
        timeout = 3000,
      },
      statuscolumn = {
        enabled = true,
        left = { "mark", "sign" },
        right = { "fold", "git" },
        folds = {
          open = true,
          git_hl = true,
        },
        git = {
          patterns = { "GitSign", "MiniDiffSign" },
        },
        refresh = 180,
      },
      styles = {
        notification = {
          -- wo = { wrap = true } -- Wrap notifications
        },
      },
    },
    config = function(_, opts)
      require("snacks").setup(opts)
    end,
    keys = {
      -- Same binding as the old neo-tree toggle.
      {
        "<leader>e",
        function()
          Snacks.explorer()
        end,
        desc = "File Explorer",
      },
      {
        "<leader>z",
        function()
          Snacks.zen.zoom()
        end,
        desc = "Toggle Zoom",
      },
      {
        "<leader>Z",
        function()
          Snacks.zen()
        end,
        desc = "Toggle Zen Mode",
      },
      {
        "<leader>un",
        function()
          Snacks.notifier.hide()
        end,
        desc = "Dismiss All Notifications",
      },
      {
        "]]",
        function()
          Snacks.words.jump(vim.v.count1)
        end,
        desc = "Next Reference",
        mode = { "n", "t" },
      },
      {
        "[[",
        function()
          Snacks.words.jump(-vim.v.count1)
        end,
        desc = "Prev Reference",
        mode = { "n", "t" },
      },
    },
    init = function()
      -- Hybrid line numbers: relative within +-5 lines of the cursor, absolute
      -- beyond that. Snacks hardcodes pure relative numbers, so rewrite the
      -- number it renders. Safe with Snacks' per-line cache: its key already
      -- contains lnum and relnum.
      local near = 5
      local sc = require("snacks.statuscolumn")
      local orig_get = sc._get
      sc._get = function()
        local ret = orig_get()
        if vim.v.virtnum == 0 and vim.v.relnum > near then
          ret = ret:gsub("%%=%d+ ", function()
            return "%=" .. vim.v.lnum .. " "
          end, 1)
        end
        return ret
      end

      -- gruber-darker.nvim doesn't style Snacks' picker/explorer highlight
      -- groups, so file/dir text and row/col numbers fall back to
      -- undifferentiated defaults; patch them in on every colorscheme load.
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          local beige_hl = { fg = "#ccac93", link = nil }
          local purple_hl = { fg = "#9e95c7", link = nil }
          vim.api.nvim_set_hl(0, "SnacksPickerDir", beige_hl)
          vim.api.nvim_set_hl(0, "SnacksPickerPathHidden", beige_hl)
          vim.api.nvim_set_hl(0, "SnacksPickerComment", beige_hl)
          vim.api.nvim_set_hl(0, "SnacksPickerRow", purple_hl)
          vim.api.nvim_set_hl(0, "SnacksPickerCol", purple_hl)
        end,
      })
      vim.api.nvim_exec_autocmds("ColorScheme", {})

      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
          Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
          Snacks.toggle.diagnostics():map("<leader>ud")
          Snacks.toggle.line_number():map("<leader>ul")
          Snacks.toggle
            .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
            :map("<leader>uc")
          Snacks.toggle.treesitter():map("<leader>uT")
          Snacks.toggle.inlay_hints():map("<leader>uh")
          Snacks.toggle.indent():map("<leader>ug")
          Snacks.toggle.dim():map("<leader>uD")
        end,
      })
    end,
  },
}
