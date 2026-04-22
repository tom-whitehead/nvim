require('lazydev').setup {
  library = {
    { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
    vim.fn.expand '~/.hammerspoon/Spoons/EmmyLua.spoon/annotations',
  },
}
