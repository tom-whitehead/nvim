-- Build hooks (must be registered before vim.pack.add)
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind
    if kind ~= 'install' and kind ~= 'update' then
      return
    end

    local path = vim.fn.stdpath('data') .. '/site/pack/core/opt/' .. name

    if name == 'nvim-treesitter' then
      if not ev.data.active then
        vim.cmd.packadd('nvim-treesitter')
      end
      vim.cmd('TSUpdate')
    elseif name == 'telescope-fzf-native.nvim' and vim.fn.executable('make') == 1 then
      vim.fn.system({ 'make', '-C', path })
    elseif name == 'LuaSnip' and vim.fn.executable('make') == 1 and vim.fn.has('win32') == 0 then
      vim.fn.system({ 'make', 'install_jsregexp', '-C', path })
    end
  end,
})

-- Install and load all plugins
vim.pack.add({
  -- Colorscheme
  'https://github.com/projekt0n/github-nvim-theme',

  -- Editor
  'https://github.com/NMAC427/guess-indent.nvim',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/echasnovski/mini.nvim',
  'https://github.com/windwp/nvim-autopairs',

  -- Telescope
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
  'https://github.com/nvim-telescope/telescope-ui-select.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',

  -- Completion
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('1.x') },
  { src = 'https://github.com/L3MON4D3/LuaSnip', version = vim.version.range('2.x') },

  -- Treesitter
  'https://github.com/nvim-treesitter/nvim-treesitter',

  -- LSP
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/mason-org/mason-lspconfig.nvim',
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
  'https://github.com/j-hui/fidget.nvim',

  -- Formatting & Linting
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/mfussenegger/nvim-lint',

  -- Git
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/FabijanZulj/blame.nvim',
  'https://github.com/f-person/git-blame.nvim',

  -- DAP
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/mfussenegger/nvim-dap-python',

  -- UI
  'https://github.com/folke/noice.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
  'https://github.com/rcarriga/nvim-notify',
  'https://github.com/folke/snacks.nvim',

  -- Misc
  'https://github.com/MeanderingProgrammer/render-markdown.nvim',
  'https://github.com/lukas-reineke/indent-blankline.nvim',
  'https://github.com/folke/todo-comments.nvim',
  'https://github.com/folke/lazydev.nvim',
  'https://github.com/shortcuts/no-neck-pain.nvim',
  'https://github.com/cajames/copy-reference.nvim',
  'https://github.com/github/copilot.vim',
}, { confirm = false })

-- vim.pack.add during init.lua registers/installs but does not load by default.
-- Explicitly load all registered packages onto the runtimepath.
for _, pkg in ipairs(vim.pack.get()) do
  vim.cmd('packadd ' .. pkg.spec.name)
end

-- Configure plugins (order matters: colorscheme first, LSP after completion)
require 'plugins.ui'
require 'plugins.editor'
require 'plugins.telescope'
require 'plugins.lazydev'
require 'plugins.completion'
require 'plugins.treesitter'
require 'plugins.git'
require 'plugins.formatting'
require 'plugins.lint'
require 'plugins.dap'
require 'plugins.noice'
require 'plugins.snacks'
require 'plugins.no-neck-pain'
require 'plugins.copy-reference'
require 'lsp.core'
