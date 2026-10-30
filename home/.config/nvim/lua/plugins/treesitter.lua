return {
  "nvim-treesitter/nvim-treesitter",
  -- Now on Neovim 0.12.5: use the "main" branch (the current rewrite,
  -- requires >=0.12). "master" -- what this was pinned to for 0.11.6 -- is
  -- frozen and now *itself* incompatible: its query_predicates.lua calls
  -- into Neovim's evolving core `vim.treesitter` API in a way that crashes
  -- ("attempt to call method 'range' (a nil value)") against 0.12's
  -- get_range/get_node_text, e.g. via markview/snacks.scope injections.
  branch = "main",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    -- "main"'s setup() only understands `install_dir`; there is no
    -- ensure_installed/highlight.enable anymore. Highlighting must be
    -- started explicitly per buffer -- see :h treesitter-highlight.
    require("nvim-treesitter").setup()
    require("nvim-treesitter").install({
      "c", "lua", "vim", "vimdoc", "bash", "terraform", "python",
      "yaml", "json", "markdown", "markdown_inline", "toml", "dockerfile",
    })

    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        -- pcall: no-op for filetypes with no installed/available parser.
        pcall(vim.treesitter.start)
        pcall(function()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end)
      end,
    })
  end,
}
