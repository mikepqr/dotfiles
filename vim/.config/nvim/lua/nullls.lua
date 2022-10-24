local null_ls = require("null-ls")

local sources = {
  null_ls.builtins.formatting.black.with({
    extra_args = { "--line-length=100" },
  }),
  null_ls.builtins.formatting.isort,
  null_ls.builtins.diagnostics.flake8.with({
    extra_args = { "--append-config", vim.fn.expand("~/.config/flake8") }
  }),
  null_ls.builtins.formatting.shfmt,
  null_ls.builtins.diagnostics.shellcheck.with({
    diagnostics_format = "[#{c}] #{m}"
  }),
}

local on_attach = function(client, bufnr)
  if client.server_capabilities.documentFormattingProvider then
    vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.format({ async = false })")
  end
end

null_ls.setup({
  sources = sources,
  on_attach = on_attach
  -- debug = true
})
