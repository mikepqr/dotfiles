local null_ls = require("null-ls")

local sources = {
  null_ls.builtins.formatting.black,
  null_ls.builtins.formatting.isort,
  require("none-ls.diagnostics.flake8").with({
    extra_args = { "--append-config", vim.fn.expand("~/.config/flake8") }
  }),
  null_ls.builtins.formatting.shfmt.with({
    extra_args = { "-i", vim.opt.shiftwidth:get(), "-ci" }
  }),
  null_ls.builtins.diagnostics.shellcheck.with({
    diagnostics_format = "[#{c}] #{m}"
  }),
}

local on_attach = function(client, bufnr)
  if client.server_capabilities.documentFormattingProvider then
    vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.format({ async = false })")
  end
  -- neovim 0.8 sets formatexpr (and therefore gq) to use LSP for any buffer to
  -- which an LSP that declares formatting capabilities is attached. null-ls
  -- declares all capabilities (incl. formatting), so this always happens for
  -- python and sh. I don't want this, so I reset formatexpr when this happens.
  -- See https://github.com/jose-elias-alvarez/null-ls.nvim/issues/1131
  vim.api.nvim_buf_set_option(bufnr, 'formatexpr', '')
end

null_ls.setup({
  sources = sources,
  on_attach = on_attach
  -- debug = true
})
