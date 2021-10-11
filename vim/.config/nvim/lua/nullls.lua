local null_ls = require("null-ls")

-- override shellcheck on PATH if installed in /usr/local/bin/shellcheck
local shfmt_path = vim.fn.filereadable("/usr/local/bin/shellcheck") == 1 and "/usr/local/bin/shellcheck" or "shellcheck"

local sources = {
    null_ls.builtins.formatting.black,
    null_ls.builtins.formatting.isort,
    null_ls.builtins.diagnostics.flake8,
    null_ls.builtins.formatting.shfmt.with({
        extra_args = { "-i", vim.opt.shiftwidth:get(), "-ci" }
    }),
    null_ls.builtins.diagnostics.shellcheck.with({
        command = shfmt_path,
        diagnostics_format = "[#{c}] #{m}"
    }),
}

null_ls.config({
    sources = sources
})

local on_attach = function(client, bufnr)
    if client.resolved_capabilities.document_formatting then
        vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
    end
end

require("lspconfig")["null-ls"].setup({
    on_attach = on_attach
})
