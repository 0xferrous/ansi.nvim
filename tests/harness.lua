local M = {
  suites = {},
  current_suite = nil,
}

local function ensure_suite()
  assert(M.current_suite, 'No active test suite. Call describe() before it().')
  return M.current_suite
end

_G.describe = function(name, fn)
  local parent = M.current_suite
  local suite = {
    name = name,
    tests = {},
    before_each = {},
    after_each = {},
    parent = parent,
  }

  if parent then
    table.insert(parent.tests, { type = 'suite', value = suite })
  else
    table.insert(M.suites, suite)
  end

  M.current_suite = suite
  fn()
  M.current_suite = parent
end

_G.it = function(name, fn)
  table.insert(ensure_suite().tests, {
    type = 'test',
    name = name,
    fn = fn,
  })
end

_G.before_each = function(fn)
  table.insert(ensure_suite().before_each, fn)
end

_G.after_each = function(fn)
  table.insert(ensure_suite().after_each, fn)
end

local builtin_assert = _G.assert
if type(_G.assert) ~= 'table' then
  _G.assert = setmetatable({}, {
    __call = function(_, condition, message)
      return builtin_assert(condition, message)
    end,
  })
end

assert.are = assert.are or {}
assert.is_true = assert.is_true or function(value, message)
  if value ~= true then
    error(message or ('Expected true, got ' .. tostring(value)), 2)
  end
end
assert.are.equal = assert.are.equal or function(expected, actual, message)
  if expected ~= actual then
    error(message or string.format('Expected %s, got %s', vim.inspect(expected), vim.inspect(actual)), 2)
  end
end

local function collect_hooks(suite, key)
  local hooks = {}
  local chain = {}
  local current = suite

  while current do
    table.insert(chain, 1, current)
    current = current.parent
  end

  for _, item in ipairs(chain) do
    for _, hook in ipairs(item[key]) do
      table.insert(hooks, hook)
    end
  end

  if key == 'after_each' then
    local reversed = {}
    for i = #hooks, 1, -1 do
      table.insert(reversed, hooks[i])
    end
    return reversed
  end

  return hooks
end

local function run_suite(suite, results, prefix)
  prefix = prefix and (prefix .. ' ') or ''
  local suite_prefix = prefix .. suite.name

  for _, entry in ipairs(suite.tests) do
    if entry.type == 'suite' then
      run_suite(entry.value, results, suite_prefix)
    else
      local full_name = suite_prefix .. ' ' .. entry.name
      local ok, err = true, nil

      for _, hook in ipairs(collect_hooks(suite, 'before_each')) do
        local hook_ok, hook_err = pcall(hook)
        if not hook_ok then
          ok, err = false, hook_err
          break
        end
      end

      if ok then
        local test_ok, test_err = pcall(entry.fn)
        if not test_ok then
          ok, err = false, test_err
        end
      end

      for _, hook in ipairs(collect_hooks(suite, 'after_each')) do
        local hook_ok, hook_err = pcall(hook)
        if ok and not hook_ok then
          ok, err = false, hook_err
        end
      end

      if ok then
        print('✓ ' .. full_name)
        results.passed = results.passed + 1
      else
        print('✗ ' .. full_name .. ': ' .. tostring(err))
        results.failed = results.failed + 1
      end
    end
  end
end

function M.run()
  local results = { passed = 0, failed = 0 }

  for _, suite in ipairs(M.suites) do
    run_suite(suite, results)
  end

  print('\nTest Results:')
  print('Passed: ' .. results.passed)
  print('Failed: ' .. results.failed)

  if results.failed > 0 then
    os.exit(1)
  end
end

return M
