local lsp = require('lsp-zero').preset({})

lsp.ensure_installed({'eslint'})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
  lsp.buffer_autoformat()
end)

lsp.setup()

lsp.format_on_save({
  format_opts = {
    async = true,
    timeout_ms = 10000,
  },
  servers = {
    ['deno'] = {'javascript'},
    ['lua_ls'] = {'lua'},
    ['rust_analyzer'] = {'rust'},
  }
})

lsp.setup()

local mason_null_ls_status, mason_null_ls = pcall(require, "mason-null-ls")
if not mason_null_ls_status then
    return
end

mason_null_ls.setup({
  ensure_installed = {
    "prettierd",
    "prettier",
    "eslint_d",

  }
})
