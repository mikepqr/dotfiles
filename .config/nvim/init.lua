--
-- behavior
--
vim.o.undofile = true
vim.opt.shada = { "'1000" }
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.wildmode = "longest,list"
vim.o.scrolloff = 5
-- jump to last position when reopening files
vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    if vim.bo.filetype == 'gitcommit' or vim.bo.filetype == 'gitrebase' or bufname:match('COMMIT_EDITMSG') or bufname:match('MERGE_MSG') then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
-- clear formatexpr so gq uses textwidth/formatoptions
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function()
    vim.bo.formatexpr = ''
  end,
})

--
-- editing
--
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.textwidth = 79
vim.o.formatoptions = "cqjnl"

--
-- keymaps
--
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')
vim.keymap.set('n', '<Leader><space>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<Leader>w', '<cmd>bdelete<CR>')
vim.keymap.set('n', 'ss', '<C-w>s', { silent = true })
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'References' })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover' })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic' })
vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end, { desc = 'Previous diagnostic' })
vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end, { desc = 'Next diagnostic' })
vim.keymap.set('n', '[q', ':cprev<CR>', { desc = 'Previous quickfix' })
vim.keymap.set('n', ']q', ':cnext<CR>', { desc = 'Next quickfix' })
vim.keymap.set('n', '[b', ':bprevious<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', ']b', ':bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', ']p', 'o<Esc>p', { desc = 'Paste below on new line' })
vim.keymap.set('n', '[p', 'O<Esc>p', { desc = 'Paste above on new line' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostic list' })

--
-- appearance
--
vim.o.signcolumn = 'yes'
vim.o.cursorline = true
vim.o.colorcolumn = "80"
vim.o.list = true
vim.o.number = true
vim.api.nvim_set_hl(0, 'ColorColumn', { link = 'CursorLine' })
-- TODO: remove in nvim 0.12 (becomes default)
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- LSP diagnostic appearance
vim.diagnostic.config({
  float = {
    border = 'rounded',  -- or 'single', 'double', 'solid'
    source = 'always',   -- show source of diagnostic
  },
  virtual_text = {
    prefix = '●',  -- could be '■', '▎', '●', etc.
    spacing = 4,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

--
-- plugins
--
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  'christoomey/vim-tmux-navigator',
  {
    'stevearc/oil.nvim',
    opts = {},
    keys = {
      { '-', '<cmd>Oil<cr>', desc = 'Open parent directory' },
    },
  },

  -- Buffer tabline
  'ap/vim-buftabline',

  -- LSP
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', opts = {} },
      { 'williamboman/mason-lspconfig.nvim', opts = {
        ensure_installed = { 'pyright', 'ruff' },
        automatic_enable = true,
      }},
      'saghen/blink.cmp',
    },
    config = function()
      local capabilities = require('blink.cmp').get_lsp_capabilities()
      vim.lsp.config('*', { capabilities = capabilities })
    end,
  },

  -- Completion
  {
    'saghen/blink.cmp',
    version = '1.*',
    opts = {
      keymap = { preset = 'super-tab' },
      appearance = { nerd_font_variant = 'mono' },
      sources = { default = { 'lsp', 'path', 'buffer' } },
    },
  },

  -- Fuzzy finder
  {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      grep = { rg_opts = '--hidden -g "!.git/" --column --line-number --no-heading --color=always --smart-case' },
    },
    keys = {
      { '<leader>f', '<cmd>lua require("fzf-lua").files()<cr>', desc = 'Find files' },
      { '<leader>h', '<cmd>lua require("fzf-lua").oldfiles()<cr>', desc = 'Recent files' },
      { '<leader>b', '<cmd>lua require("fzf-lua").buffers()<cr>', desc = 'Buffers' },
      { '<leader>/', '<cmd>lua require("fzf-lua").live_grep()<cr>', desc = 'Grep' },
    },
  },

  -- Git signs
  {
    'lewis6991/gitsigns.nvim',
    opts = {},
  },

  -- Formatting
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        python = { 'ruff_organize_imports', 'ruff_format' },
      },
      format_on_save = { timeout_ms = 500 },
    },
  },

})
