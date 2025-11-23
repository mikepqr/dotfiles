require('nvim-treesitter.configs').setup {
  ensure_installed = {
    "bash",
    "python"
  },
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = 'gnn',
      node_incremental = 'grn',
      scope_incremental = 'grc',
      node_decremental = 'grm',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects#built-in-textobjects
        ['ab'] = '@block.outer',
        ['ib'] = '@block.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        -- ['ac'] = '@class.outer',
        -- ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']]'] = '@function.outer',
        [']m'] = '@class.outer',
      },
      goto_previous_start = {
        ['[['] = '@function.outer',
        ['[m'] = '@class.outer',
      },
      -- goto_next_end = {
      --   [']M'] = '@function.outer',
      --   [']['] = '@class.outer',
      -- },
      -- goto_previous_end = {
      --   ['[M'] = '@function.outer',
      --   ['[]'] = '@class.outer',
      -- },
    },
  },
}
