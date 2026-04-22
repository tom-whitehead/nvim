vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
    map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
    map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
    map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
    map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
        end,
      })
    end

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
      end, '[T]oggle Inlay [H]ints')
    end
  end,
})

vim.diagnostic.config {
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
  virtual_text = {
    source = 'if_many',
    spacing = 2,
    format = function(diagnostic)
      local diagnostic_message = {
        [vim.diagnostic.severity.ERROR] = diagnostic.message,
        [vim.diagnostic.severity.WARN] = diagnostic.message,
        [vim.diagnostic.severity.INFO] = diagnostic.message,
        [vim.diagnostic.severity.HINT] = diagnostic.message,
      }
      return diagnostic_message[diagnostic.severity]
    end,
  },
}

local capabilities = require('blink.cmp').get_lsp_capabilities()

-- Workaround: some LSP servers return annotated text edits without the
-- required changeAnnotations map, causing Neovim 0.12's apply_text_edits
-- to assert. Patch the rename handler to fill in missing annotations.
do
  local orig = vim.lsp.handlers['textDocument/rename']
  vim.lsp.handlers['textDocument/rename'] = function(err, result, ctx, config)
    if result and result.documentChanges then
      for _, change in ipairs(result.documentChanges) do
        if change.edits then
          for _, edit in ipairs(change.edits) do
            if edit.annotationId and not result.changeAnnotations then
              result.changeAnnotations = {}
            end
            if edit.annotationId and not result.changeAnnotations[edit.annotationId] then
              result.changeAnnotations[edit.annotationId] = {
                label = edit.annotationId,
                needsConfirmation = false,
              }
            end
          end
        end
      end
    end
    return orig(err, result, ctx, config)
  end
end

local servers = {
  pyright = {},
  rust_analyzer = {
    ['rust-analyzer'] = {
      checkOnSave = {
        command = 'clippy',
      },
    },
  },
  lua_ls = {
    settings = {
      Lua = {
        completion = { callSnippet = 'Replace' },
        diagnostics = { globals = { 'hs', 'spoon' } },
      },
    },
  },
}

require('mason').setup {}
require('fidget').setup {}

local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, { 'stylua', 'ruff' })
require('mason-tool-installer').setup { ensure_installed = ensure_installed }

require('mason-lspconfig').setup {
  ensure_installed = {},
  automatic_installation = false,
  handlers = {
    function(server_name)
      local server = servers[server_name] or {}
      server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
      require('lspconfig')[server_name].setup(server)
    end,
  },
}

-- Swift sourcekit-lsp (native, not managed by Mason)
do
  local function swift_root_dir(bufnr)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if bufname == '' then
      return vim.uv.cwd()
    end
    local start = vim.fs.dirname(bufname)
    local match = vim.fs.find(function(name, _)
      if name == 'Package.swift' or name == '.git' then
        return true
      end
      return name:match '%.xcodeproj$' or name:match '%.xcworkspace$'
    end, { path = start, upward = true })[1]
    return match and vim.fs.dirname(match) or start
  end

  local grp = vim.api.nvim_create_augroup('swift-sourcekit-native', { clear = true })
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'swift',
    group = grp,
    callback = function(args)
      local root = swift_root_dir(args.buf)
      vim.lsp.start {
        name = 'sourcekit',
        cmd = { 'sourcekit-lsp' },
        root_dir = root,
        capabilities = capabilities,
        single_file_support = true,
        reuse_client = function(client, conf)
          return client.name == 'sourcekit' and client.config.root_dir == conf.root_dir
        end,
      }
    end,
  })
end
