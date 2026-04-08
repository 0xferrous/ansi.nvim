-- Tests for ansi.init module
-- Tests auto_enable functionality with separate stdin option
-- Run with: nvim --headless -c "luafile tests/init_spec.lua" -c "qa"

-- Set up package path for nvim's Lua runtime
local this_file = debug.getinfo(1, 'S').source:sub(2)
local test_dir = vim.fn.fnamemodify(this_file, ':h')
local root_dir = vim.fn.fnamemodify(test_dir, ':h')
-- Support both file.lua and file/init.lua patterns
package.path = package.path .. ';' .. root_dir .. '/lua/?.lua;' .. root_dir .. '/lua/?/init.lua'

-- Count autocmds for given events
local function count_autocmds(events)
  local count = 0
  for _, event in ipairs(events) do
    local autocmds = vim.api.nvim_get_autocmds({ event = event })
    count = count + #autocmds
  end
  return count
end

-- Delete all autocmds we can (for cleanup between tests)
local function clear_all_autocmds()
  local events = { 'FileType', 'StdinReadPost' }
  for _, event in ipairs(events) do
    local autocmds = vim.api.nvim_get_autocmds({ event = event })
    for _, autocmd in ipairs(autocmds) do
      pcall(vim.api.nvim_del_autocmd, autocmd.id)
    end
  end
end

local function test(name, fn)
  local success, err = pcall(fn)
  if success then
    print("✓ " .. name)
    return true
  else
    print("✗ " .. name .. ": " .. tostring(err))
    return false
  end
end

local function run_tests()
  print("Running ANSI Init Tests...\n")

  local passed = 0
  local failed = 0

  -- Test 1: FileType autocmd created when auto_enable is true
  if test("creates FileType autocmd when auto_enable is true", function()
    package.loaded['ansi'] = nil
    package.loaded['ansi.renderer'] = nil
    clear_all_autocmds()

    local before = count_autocmds({ 'FileType' })

    local ansi = require('ansi')
    ansi.setup({
      auto_enable = true,
      filetypes = { 'log', 'ansi' },
    })

    local after = count_autocmds({ 'FileType' })
    assert(after > before, "FileType autocmd should be created")
  end) then passed = passed + 1 else failed = failed + 1 end

  -- Test 2: StdinReadPost autocmd created when auto_enable_stdin is true
  if test("creates StdinReadPost autocmd when auto_enable_stdin is true", function()
    package.loaded['ansi'] = nil
    package.loaded['ansi.renderer'] = nil
    clear_all_autocmds()

    local before = count_autocmds({ 'StdinReadPost' })

    local ansi = require('ansi')
    ansi.setup({
      auto_enable_stdin = true,
    })

    local after = count_autocmds({ 'StdinReadPost' })
    assert(after > before, "StdinReadPost autocmd should be created")
  end) then passed = passed + 1 else failed = failed + 1 end

  -- Test 3: Both autocmds can be enabled independently
  if test("both autocmds can be enabled independently", function()
    package.loaded['ansi'] = nil
    package.loaded['ansi.renderer'] = nil
    clear_all_autocmds()

    local before_filetype = count_autocmds({ 'FileType' })
    local before_stdin = count_autocmds({ 'StdinReadPost' })

    local ansi = require('ansi')
    ansi.setup({
      auto_enable = true,
      auto_enable_stdin = true,
      filetypes = { 'log' },
    })

    local after_filetype = count_autocmds({ 'FileType' })
    local after_stdin = count_autocmds({ 'StdinReadPost' })

    assert(after_filetype > before_filetype, "FileType autocmd should be created")
    assert(after_stdin > before_stdin, "StdinReadPost autocmd should be created")
  end) then passed = passed + 1 else failed = failed + 1 end

  -- Test 4: No autocmds created when both are false
  if test("creates no autocmds when both are false", function()
    package.loaded['ansi'] = nil
    package.loaded['ansi.renderer'] = nil
    clear_all_autocmds()

    local before_filetype = count_autocmds({ 'FileType' })
    local before_stdin = count_autocmds({ 'StdinReadPost' })

    local ansi = require('ansi')
    ansi.setup({
      auto_enable = false,
      auto_enable_stdin = false,
      filetypes = { 'log' },
    })

    local after_filetype = count_autocmds({ 'FileType' })
    local after_stdin = count_autocmds({ 'StdinReadPost' })

    assert(after_filetype == before_filetype, "Should not create FileType autocmd")
    assert(after_stdin == before_stdin, "Should not create StdinReadPost autocmd")
  end) then passed = passed + 1 else failed = failed + 1 end

  -- Test 5: auto_enable_stdin alone doesn't create FileType autocmd
  if test("auto_enable_stdin alone doesn't create FileType autocmd", function()
    package.loaded['ansi'] = nil
    package.loaded['ansi.renderer'] = nil
    clear_all_autocmds()

    local before = count_autocmds({ 'FileType' })

    local ansi = require('ansi')
    ansi.setup({
      auto_enable = false,
      auto_enable_stdin = true,
    })

    local after = count_autocmds({ 'FileType' })
    assert(after == before, "FileType autocmd should NOT be created when only auto_enable_stdin is true")
  end) then passed = passed + 1 else failed = failed + 1 end

  -- Test 6: auto_enable alone doesn't create StdinReadPost autocmd
  if test("auto_enable alone doesn't create StdinReadPost autocmd", function()
    package.loaded['ansi'] = nil
    package.loaded['ansi.renderer'] = nil
    clear_all_autocmds()

    local before = count_autocmds({ 'StdinReadPost' })

    local ansi = require('ansi')
    ansi.setup({
      auto_enable = true,
      auto_enable_stdin = false,
      filetypes = { 'log' },
    })

    local after = count_autocmds({ 'StdinReadPost' })
    assert(after == before, "StdinReadPost autocmd should NOT be created when only auto_enable is true")
  end) then passed = passed + 1 else failed = failed + 1 end

  print("\nTest Results:")
  print("Passed: " .. passed)
  print("Failed: " .. failed)

  if failed > 0 then
    os.exit(1)
  else
    print("All tests passed!")
  end
end

run_tests()
