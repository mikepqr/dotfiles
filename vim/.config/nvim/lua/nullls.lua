local null_ls = require("null-ls")

local sources = {
    null_ls.builtins.formatting.black,
    null_ls.builtins.formatting.isort,
    null_ls.builtins.diagnostics.flake8,
    null_ls.builtins.formatting.shfmt.with({
        extra_args = { "-i", "4", "-ci" }
    }),
    null_ls.builtins.diagnostics.shellcheck.with({
        diagnostics_format = "[#{c}] #{m}"
    }),
}

null_ls.config({ sources = sources, debug = true })
require("lspconfig")["null-ls"].setup({
    on_attach = function(client)
        if client.resolved_capabilities.document_formatting then
            vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
        end
    end
})
