return {
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },
  {
    'FabijanZulj/blame.nvim',
    lazy = false,
    config = function()
      require('blame').setup {}
    end,
  },
  {
    'f-person/git-blame.nvim',
    event = 'VeryLazy',
    config = function()
      -- Function to derive URL template dynamically
      local function get_github_url_template()
        -- Read the origin URL
        local handle = io.popen 'git config --get remote.origin.url 2>/dev/null'
        if not handle then
          return nil
        end

        local origin = handle:read '*a'
        handle:close()

        origin = origin and origin:gsub('%s+$', '') -- trim newline

        if not origin or origin == '' then
          return nil
        end

        -- Normalize ssh → https
        -- git@github.com:user/repo.git → https://github.com/user/repo
        local user, repo = origin:match 'git@github%.com:(.-)/(.-)%.git'
          or origin:match 'git@github%.com:(.-)/(.-)$'
          or origin:match 'https://github%.com/(.-)/(.-)%.git'
          or origin:match 'https://github%.com/(.-)/(.-)$'

        if user and repo then
          return string.format('https://github.com/%s/%s/commit/%%s', user, repo)
        end

        return nil
      end

      local url_template = get_github_url_template()

      require('gitblame').setup {
        enabled = true,
        message_template = ' <summary> • <date> • <author>',
        date_format = '%r',
        virtual_text_column = 1,
        url_template = url_template,
      }
    end,
  },
}
