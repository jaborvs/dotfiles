return {
  "neovim/nvim-lspconfig",
  dependencies = {
    -- Optional: Provides nice structural progress updates as local indexers load
    { "j-hui/fidget.nvim", opts = {} },
    "saghen/blink.cmp",
  },
  config = function()
    -- Give every server blink.cmp's completion capabilities (snippets,
    -- resolve support, etc.) instead of Neovim's plain defaults.
    vim.lsp.config('*', {
      capabilities = require('blink.cmp').get_lsp_capabilities(),
    })

    -- Enable your local servers using the v0.11+ native core functions.
    -- Neovim is now 0.12.5, so nvim-lspconfig's stock terraformls.lua
    -- on_attach (which calls vim.lsp.codelens.enable, a >=0.12-only API)
    -- works as-is -- no override needed anymore.
    vim.lsp.enable('bashls')
    vim.lsp.enable('basedpyright')
    vim.lsp.enable('terraformls')

    -- Lua LSP for editing this very config (and any other Lua you write).
    vim.lsp.config('lua_ls', {
      settings = {
        Lua = {
          completion = { callSnippet = 'Replace' },
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
        },
      },
    })
    vim.lsp.enable('lua_ls')

    -- Universal Keybindings (Triggers cleanly on native Neovim LspAttach event)
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
      callback = function(ev)
        local opts = { buffer = ev.buf }
        
        -- gd -> Jump to Definition (See variable/module mapping origins)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        
        -- K -> Hover (Read exact flag context and property manual pages)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        
        -- <space>rn -> Smart Rename (Refactor variable instances across the workspace)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        
        -- <space>e -> Diagnostic (Open floating window to view local compilation syntax failures)
        vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
      end,
    })

    -- Workspace Correction: Map Terragrunt & vars cleanly to standard Terraform types
    vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
      pattern = {"*.hcl", "*.tfvars"},
      callback = function()
        vim.bo.filetype = "terraform"
      end,
    })
  end
}
