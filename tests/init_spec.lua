local function count_autocmds(events)
  local count = 0
  for _, event in ipairs(events) do
    local autocmds = vim.api.nvim_get_autocmds({ event = event })
    count = count + #autocmds
  end
  return count
end

local function clear_all_autocmds()
  local events = { 'FileType', 'StdinReadPost' }
  for _, event in ipairs(events) do
    local autocmds = vim.api.nvim_get_autocmds({ event = event })
    for _, autocmd in ipairs(autocmds) do
      pcall(vim.api.nvim_del_autocmd, autocmd.id)
    end
  end
end

describe('ansi.setup', function()
  before_each(function()
    package.loaded['ansi'] = nil
    package.loaded['ansi.renderer'] = nil
    clear_all_autocmds()
  end)

  after_each(function()
    package.loaded['ansi'] = nil
    package.loaded['ansi.renderer'] = nil
    clear_all_autocmds()
  end)

  it('creates FileType autocmd when auto_enable is true', function()
    local before = count_autocmds({ 'FileType' })

    local ansi = require('ansi')
    ansi.setup({
      auto_enable = true,
      filetypes = { 'log', 'ansi' },
    })

    local after = count_autocmds({ 'FileType' })
    assert.is_true(after > before, 'FileType autocmd should be created')
  end)

  it('creates StdinReadPost autocmd when auto_enable_stdin is true', function()
    local before = count_autocmds({ 'StdinReadPost' })

    local ansi = require('ansi')
    ansi.setup({
      auto_enable_stdin = true,
    })

    local after = count_autocmds({ 'StdinReadPost' })
    assert.is_true(after > before, 'StdinReadPost autocmd should be created')
  end)

  it('can enable both autocmds independently', function()
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

    assert.is_true(after_filetype > before_filetype, 'FileType autocmd should be created')
    assert.is_true(after_stdin > before_stdin, 'StdinReadPost autocmd should be created')
  end)

  it('creates no autocmds when both are false', function()
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

    assert.are.equal(before_filetype, after_filetype, 'Should not create FileType autocmd')
    assert.are.equal(before_stdin, after_stdin, 'Should not create StdinReadPost autocmd')
  end)

  it("does not create FileType autocmd when only auto_enable_stdin is true", function()
    local before = count_autocmds({ 'FileType' })

    local ansi = require('ansi')
    ansi.setup({
      auto_enable = false,
      auto_enable_stdin = true,
    })

    local after = count_autocmds({ 'FileType' })
    assert.are.equal(before, after, 'FileType autocmd should not be created')
  end)

  it("does not create StdinReadPost autocmd when only auto_enable is true", function()
    local before = count_autocmds({ 'StdinReadPost' })

    local ansi = require('ansi')
    ansi.setup({
      auto_enable = true,
      auto_enable_stdin = false,
      filetypes = { 'log' },
    })

    local after = count_autocmds({ 'StdinReadPost' })
    assert.are.equal(before, after, 'StdinReadPost autocmd should not be created')
  end)
end)
