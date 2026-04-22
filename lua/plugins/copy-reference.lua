require('copy-reference').setup {}

vim.keymap.set({ 'n', 'v' }, '<leader>cr', '<cmd>CopyReference file<cr>', { desc = '[C]opy file [r]eference' })
vim.keymap.set({ 'n', 'v' }, '<leader>cl', '<cmd>CopyReference line<cr>', { desc = '[C]opy [l]ine reference' })
