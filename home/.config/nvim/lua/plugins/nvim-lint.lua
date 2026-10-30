return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  keys = {
    {
      "<leader>rl",
      function()
        require("lint").try_lint()
      end,
      desc = "Lint buffer",
    },
  },
  config = function()
    local lint = require("lint")
    lint.linters_by_ft = {
      sh = { "shellcheck" },
      bash = { "shellcheck" },
      terraform = { "tflint" },
      markdown = { "markdownlint" },
      dockerfile = { "hadolint" },
    }

    vim.api.nvim_create_autocmd("BufWritePost", {
      group = vim.api.nvim_create_augroup("nvim-lint-auto", { clear = true }),
      callback = function(args)
        if vim.b[args.buf].disable_lint then
          return
        end
        lint.try_lint(nil, { buf = args.buf })
      end,
    })
  end,
}
