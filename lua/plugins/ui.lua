-- Colorscheme
require('github-theme').setup {}
vim.cmd.colorscheme 'github_dark_default'

local function toggle_theme()
  local current = vim.g.colors_name

  if string.find(current, 'dark') then
    vim.cmd.colorscheme 'github_light'
  else
    vim.cmd.colorscheme 'github_dark_default'
  end
end

vim.keymap.set('n', '<leader>ut', toggle_theme, { desc = 'Toggle theme (light/dark)' })

-- UI plugins
require('render-markdown').setup {}
require('ibl').setup {}
require('todo-comments').setup { signs = false }
