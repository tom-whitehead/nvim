require('snacks').setup {
  input = { enabled = true },
}

vim.keymap.set({ 'n', 'x' }, '<leader>go', function()
  Snacks.gitbrowse()
end, { desc = '[G]it [O]pen in Browser' })

vim.keymap.set({ 'n', 'x' }, '<leader>gm', function()
  Snacks.gitbrowse { branch = 'main' }
end, { desc = '[G]it Open [M]ain in Browser' })
