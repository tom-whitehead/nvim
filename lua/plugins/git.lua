require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
  on_attach = function(bufnr)
    local gitsigns = require 'gitsigns'

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal { ']c', bang = true }
      else
        gitsigns.nav_hunk 'next'
      end
    end, { desc = 'Jump to next git [c]hange' })

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal { '[c', bang = true }
      else
        gitsigns.nav_hunk 'prev'
      end
    end, { desc = 'Jump to previous git [c]hange' })

    -- Actions
    map('v', '<leader>hs', function()
      gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, { desc = 'git [s]tage hunk' })
    map('v', '<leader>hr', function()
      gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, { desc = 'git [r]eset hunk' })
    map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
    map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
    map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
    map('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = 'git [u]ndo stage hunk' })
    map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
    map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
    map('n', '<leader>hb', gitsigns.blame_line, { desc = 'git [b]lame line' })
    map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
    map('n', '<leader>hD', function()
      gitsigns.diffthis '@'
    end, { desc = 'git [D]iff against last commit' })
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
    map('n', '<leader>tD', gitsigns.preview_hunk_inline, { desc = '[T]oggle git show [D]eleted' })
  end,
}

require('blame').setup {}

-- git-blame.nvim
local function get_github_url_template()
  local handle = io.popen 'git config --get remote.origin.url 2>/dev/null'
  if not handle then
    return nil
  end

  local origin = handle:read '*a'
  handle:close()

  origin = origin and origin:gsub('%s+$', '')

  if not origin or origin == '' then
    return nil
  end

  local user, repo = origin:match 'git@github%.com:(.-)/(.-)%.git'
    or origin:match 'git@github%.com:(.-)/(.-)$'
    or origin:match 'https://github%.com/(.-)/(.-)%.git'
    or origin:match 'https://github%.com/(.-)/(.-)$'

  if user and repo then
    return string.format('https://github.com/%s/%s/commit/%%s', user, repo)
  end

  return nil
end

require('gitblame').setup {
  enabled = true,
  message_template = ' <summary> • <date> • <author>',
  date_format = '%r',
  virtual_text_column = 1,
  url_template = get_github_url_template(),
}

vim.keymap.set('n', '<leader>bt', ':BlameToggle<CR>', { silent = true, noremap = true, desc = 'Git [B]lame [T]oggle' })

vim.keymap.set('n', '<leader>gc', function()
  vim.cmd 'GitBlameOpenCommitURL'
end, { desc = 'Open [G]itHub [C]ommit' })
