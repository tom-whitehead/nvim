local modules = {
  'plugins.colorscheme',
  'plugins.editor',
  'plugins.telescope',
  'plugins.formatting',
  'plugins.completion',
  'plugins.treesitter',
  'plugins.git',
  'plugins.todo',
  'plugins.render_markdown',
  'plugins.copilot',
  'plugins.snacks',
  'plugins.dap',
  'plugins.lazydev',
  'lsp.core',
  'plugins.noice',
  'plugins.no_neck_pain',
  'plugins.copy-reference',
}

local specs = {}
for _, m in ipairs(modules) do
  local ok, mod = pcall(require, m)
  if ok and type(mod) == 'table' then
    for _, s in ipairs(mod) do
      table.insert(specs, s)
    end
  end
end

return specs
