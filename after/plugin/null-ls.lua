local status, null_ls = pcall(require, "null-ls")
if (not status) then return end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local lsp_formatting = function(bufnr)
  vim.lsp.buf.format({
    filter = function(client)
      return client.name == "null-ls"
    end,
    bufnr = bufnr,
  })
end

null_ls.setup {
  sources = {
--------------------------------------------------------------------------------
---------------------------------- PRETTIER ------------------------------------
--------------------------------------------------------------------------------
    null_ls.builtins.formatting.prettier.with({ extra_args = { 
        "--no-semi", 
        "--single-quote", 
        "--jsx-single-quote" 
    }, filetypes = { "json", "jsx", "typescript", "js" }}),

--------------------------------------------------------------------------------
------------------------------------ BLACK -------------------------------------
--------------------------------------------------------------------------------
    null_ls.builtins.formatting.black.with({ extra_args = { 
        "--line-length=80" 
    }, filetypes = {"py", "python", } }),

--------------------------------------------------------------------------------
------------------------------- CLANG-FORMATTER --------------------------------
--------------------------------------------------------------------------------
    null_ls.builtins.formatting.clang_format.with({ extra_args = { 
        "--line-length=80",
        "--style=LLVM" 
    }, filetypes = {"c", "cpp", "h" } }),


--------------------------------------------------------------------------------
---------------------------------- ESLINT_D -------------------------------------
--------------------------------------------------------------------------------
    null_ls.builtins.diagnostics.eslint_d.with({
      diagnostics_format = '[eslint] #{m}\n(#{c})'
    }),  --  null_ls.builtins.diagnostics.fish
  },

--------------------------------------------------------------------------------
------------------------------ FORMAT ON SAVE ----------------------------------
--------------------------------------------------------------------------------
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          lsp_formatting(bufnr)
        end,
      })
    end
  end
}

vim.api.nvim_create_user_command(
  'DisableLspFormatting',
  function()
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = 0 })
  end,
  { nargs = 0 }
)
