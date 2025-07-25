-- Simple test runner for ansi.nvim
-- Run with: nvim --headless -c "luafile tests/run_tests.lua" -c "qa"

local function run_parser_tests()
  print("Running ANSI Parser Tests...")
  
  -- Add the lua directory to package.path so we can require our modules
  package.path = package.path .. ";./lua/?.lua"
  
  local parser = require('ansi.parser')
  local passed = 0
  local failed = 0
  
  local function test(name, fn)
    local success, err = pcall(fn)
    if success then
      print("✓ " .. name)
      passed = passed + 1
    else
      print("✗ " .. name .. ": " .. tostring(err))
      failed = failed + 1
    end
  end
  
  -- Test parse_ansi_sequence
  test("parse reset code", function()
    local attrs = parser.parse_ansi_sequence('0')
    assert(attrs.reset == true, "Should parse reset code")
  end)
  
  test("parse foreground color", function()
    local attrs = parser.parse_ansi_sequence('31')
    assert(attrs.fg == 'red', "Should parse red foreground")
  end)
  
  test("parse background color", function()
    local attrs = parser.parse_ansi_sequence('41')
    assert(attrs.bg == 'red', "Should parse red background")
  end)
  
  test("parse bold attribute", function()
    local attrs = parser.parse_ansi_sequence('1')
    assert(attrs.bold == true, "Should parse bold attribute")
  end)
  
  test("parse combined codes", function()
    local attrs = parser.parse_ansi_sequence('1;31;42')
    assert(attrs.bold == true, "Should parse bold")
    assert(attrs.fg == 'red', "Should parse red foreground")
    assert(attrs.bg == 'green', "Should parse green background")
  end)
  
  -- Test find_ansi_sequences
  test("find single sequence", function()
    local text = 'Hello \27[31mworld\27[0m!'
    local sequences = parser.find_ansi_sequences(text)
    assert(#sequences == 2, "Should find 2 sequences")
    assert(sequences[1].attrs.fg == 'red', "Should find red color")
    assert(sequences[2].attrs.reset == true, "Should find reset")
  end)
  
  test("find multiple sequences", function()
    local text = '\27[31mRed\27[0m \27[32mGreen\27[0m'
    local sequences = parser.find_ansi_sequences(text)
    assert(#sequences == 4, "Should find 4 sequences")
    assert(sequences[1].attrs.fg == 'red', "Should find red")
    assert(sequences[3].attrs.fg == 'green', "Should find green")
  end)
  
  test("handle plain text", function()
    local text = 'Plain text without colors'
    local sequences = parser.find_ansi_sequences(text)
    assert(#sequences == 0, "Should find no sequences")
  end)
  
  print("\nTest Results:")
  print("Passed: " .. passed)
  print("Failed: " .. failed)
  
  if failed > 0 then
    print("Parser tests failed!")
    return false
  else
    print("All parser tests passed!")
    return true
  end
end

-- Run parser tests
local parser_success = run_parser_tests()

-- Run fold tests
print("\n" .. string.rep("=", 50))
local fold_success = false
local fold_test_ok, fold_err = pcall(function()
  dofile('tests/test_fold_simple.lua')
  fold_success = true
end)

if not fold_test_ok then
  print("Fold tests failed to run: " .. tostring(fold_err))
  fold_success = false
end

print("\n" .. string.rep("=", 50))
print("=== Final Results ===")
if parser_success and fold_success then
  print("✓ All tests passed!")
else
  print("✗ Some tests failed")
  print("  Parser tests: " .. (parser_success and "PASS" or "FAIL"))
  print("  Fold tests: " .. (fold_success and "PASS" or "FAIL"))
  os.exit(1)
end