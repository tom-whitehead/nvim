vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = '[E]xpand diagnostic message' })

-- Function to toggle between dark and light themes
local function toggle_theme()
  local current = vim.g.colors_name

  if string.find(current, 'dark') then
    vim.cmd.colorscheme 'github_light'
  else
    vim.cmd.colorscheme 'github_dark_default'
  end
end

vim.keymap.set('n', '<leader>ut', toggle_theme, { desc = 'Toggle theme (light/dark)' })

vim.keymap.set('n', '<leader>bt', ':BlameToggle<CR>', { silent = true, noremap = true, desc = 'Git [B]lame [T]oggle' })
