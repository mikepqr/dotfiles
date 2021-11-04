vim.opt.completeopt = { "menu", "menuone", "noselect" }

local cmp = require'cmp'
cmp.setup {
  completion = {
    autocomplete = false,
    completeopt = 'menu,menuone,noinsert',
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<esc>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm(
      {
        behavior = cmp.ConfirmBehavior.Insert,
        select = true,
      },
      {"i", "c"}
    ),
    ["<Tab>"] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_next_item()
      else
        cmp.complete()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_prev_item()
      end
    end, { "i", "s" }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
  },
  experimental = {
    -- native_menu = false,
  }
}
