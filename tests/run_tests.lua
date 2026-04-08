-- Unified test runner for ansi.nvim
-- Run with: nvim --headless -c "luafile tests/run_tests.lua" -c "qa"

local this_file = debug.getinfo(1, 'S').source:sub(2)
local test_dir = vim.fn.fnamemodify(this_file, ':h')
local root_dir = vim.fn.fnamemodify(test_dir, ':h')

package.path = package.path
  .. ';' .. root_dir .. '/lua/?.lua'
  .. ';' .. root_dir .. '/lua/?/init.lua'
  .. ';' .. test_dir .. '/?.lua'

local harness = require('harness')

for _, spec in ipairs({ 'parser_spec', 'init_spec' }) do
  package.loaded[spec] = nil
  require(spec)
end

print('Running ansi.nvim tests...\n')
harness.run()
print('All tests passed!')
