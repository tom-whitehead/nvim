return {
  {
    'cajames/copy-reference.nvim',
    opts = {}, -- optional configuration
    keys = {
      { '<leader>cr', '<cmd>CopyReference file<cr>', mode = { 'n', 'v' }, desc = '[C]opy file [r]eference' },
      { '<leader>cl', '<cmd>CopyReference line<cr>', mode = { 'n', 'v' }, desc = '[C]opy [l]ine reference' },
    },
  },
}
