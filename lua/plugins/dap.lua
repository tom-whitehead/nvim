local dap = require 'dap'
local dapui = require 'dapui'

dapui.setup()

local function pick_python()
  local venv = os.getenv 'VIRTUAL_ENV'
  if venv and #venv > 0 then
    local vpy = venv .. '/bin/python'
    if vim.fn.executable(vpy) == 1 then
      return vpy
    end
  end

  local cwd_venv = vim.fn.getcwd() .. '/.venv/bin/python'
  if vim.fn.executable(cwd_venv) == 1 then
    return cwd_venv
  end

  local py3 = vim.fn.exepath 'python3'
  if py3 and #py3 > 0 then
    return py3
  end

  local py = vim.fn.exepath 'python'
  return (py and #py > 0) and py or 'python3'
end

local adapter_python = pick_python()
require('dap-python').setup(adapter_python)

dap.configurations.python = {
  {
    type = 'python',
    request = 'attach',
    name = 'Docker Remote Attach',
    connect = {
      host = 'localhost',
      port = 5678,
    },
    pathMappings = {
      {
        localRoot = vim.fn.getcwd(),
        remoteRoot = '/app',
      },
    },
  },
  {
    type = 'python',
    request = 'launch',
    name = 'Launch File',
    program = '${file}',
    pythonPath = function()
      return adapter_python
    end,
  },
}

dap.listeners.after.event_initialized['dapui_config'] = function()
  dapui.open()
end
dap.listeners.before.event_terminated['dapui_config'] = function()
  dapui.close()
end
dap.listeners.before.event_exited['dapui_config'] = function()
  dapui.close()
end

vim.keymap.set('n', '<leader>db', function()
  dap.toggle_breakpoint()
end, { desc = '[D]AP Toggle [B]reakpoint' })
vim.keymap.set('n', '<leader>dc', function()
  dap.continue()
end, { desc = '[D]AP [C]ontinue' })
vim.keymap.set('n', '<leader>ds', function()
  dap.step_over()
end, { desc = '[D]AP [S]tep Over' })
vim.keymap.set('n', '<leader>di', function()
  dap.step_into()
end, { desc = '[D]AP Step [I]nto' })
vim.keymap.set('n', '<leader>do', function()
  dap.step_out()
end, { desc = '[D]AP Step [O]ut' })
vim.keymap.set('n', '<leader>dr', function()
  dap.repl.open()
end, { desc = '[D]AP Open [R]EPL' })
vim.keymap.set('n', '<leader>du', function()
  dapui.toggle()
end, { desc = 'Toggle [D]AP [U]I' })
