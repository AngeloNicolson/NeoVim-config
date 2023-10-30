local lsp = require('lsp-zero').preset({})


-- Ensure that 'null-ls' is a required dependency
local null_ls_status, null_ls = pcall(require, 'null-ls')
if not null_ls_status then
    return
end

-- Load the null-ls sources and settings from your 'null-ls.lua' configuration
-- This assumes that your 'null-ls.lua' file already defines the sources and their settings
require('null-ls').setup({})

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
     ['null-ls'] = { 'javascript', 'html', 'typescript', 'jsx', 'json', 'javascriptreact', 'lua', 'cpp' },
  }
})

lsp.set_sign_icons({
  error = '✘',
  warn = '▲',
  hint = '⚑',
  info = '»'
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
    "lua_ls",

  }
})


-- USE THIS FUCKING SETUP BECAUS I CANT GET AUTOFORMATTING TO WORK WITH javascrpt FILES!!!!!!!
--local lsp = require('lsp-zero').preset({})
--
--lsp.ensure_installed({'eslint'})
--
--lsp.on_attach(function(client, bufnr)
--  lsp.default_keymaps({buffer = bufnr})
--  lsp.buffer_autoformat()
--end)
--
--lsp.setup()
--
--lsp.format_on_save({
--  format_opts = {
--    async = true,
--    timeout_ms = 10000,
--  },
--  servers = {
--    ['prettierd'] = {'javascript', 'json', 'typescript', 'css'},
--    ['lua_ls'] = {'lua'},
--    ['rust_analyzer'] = {'rust'},
--    ['clangd'] = {'c','cpp', 'hpp'},
--  }
--})
--
--lsp.setup()
--
--local mason_null_ls_status, mason_null_ls = pcall(require, "mason-null-ls")
--if not mason_null_ls_status then
--    return
--end
--
--mason_null_ls.setup({
--  ensure_installed = {
--    "prettierd",
--    "prettier",
--    "eslint_d",
--    "clangd"
--
--  }
--})
--
