local dap = require 'dap-go'
return {
  {
    'mfussenegger/nvim-dap',
  },
  {
    'leoluz/nvim-dap-go',
    dependencies = { 'mfussenegger/nvim-dap' },

    config = function()
      require('dap-go').setup {
        dap_configurations = {
          type = 'go',
          name = 'Debug stuf',
          mode = 'remote',
        },
      }
    end,
  },
  vim.keymap.set('n', '<F5>', dap.debug_test, { desc = 'Debug: Start/Continue' }),
}
