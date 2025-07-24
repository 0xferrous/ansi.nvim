local parser = require('ansi.parser')

describe('ANSI Parser', function()
  describe('parse_ansi_sequence', function()
    it('should parse reset code', function()
      local attrs = parser.parse_ansi_sequence('0')
      assert.is_true(attrs.reset)
    end)
    
    it('should parse foreground colors', function()
      local attrs = parser.parse_ansi_sequence('31')
      assert.are.equal('red', attrs.fg)
    end)
    
    it('should parse background colors', function()
      local attrs = parser.parse_ansi_sequence('41')
      assert.are.equal('red', attrs.bg)
    end)
    
    it('should parse text attributes', function()
      local attrs = parser.parse_ansi_sequence('1')
      assert.is_true(attrs.bold)
      
      local attrs2 = parser.parse_ansi_sequence('3')
      assert.is_true(attrs2.italic)
      
      local attrs3 = parser.parse_ansi_sequence('4')
      assert.is_true(attrs3.underline)
    end)
    
    it('should parse combined codes', function()
      local attrs = parser.parse_ansi_sequence('1;31;42')
      assert.is_true(attrs.bold)
      assert.are.equal('red', attrs.fg)
      assert.are.equal('green', attrs.bg)
    end)
  end)
  
  describe('find_ansi_sequences', function()
    it('should find single sequence', function()
      local text = 'Hello \27[31mworld\27[0m!'
      local sequences = parser.find_ansi_sequences(text)
      
      assert.are.equal(2, #sequences)
      assert.are.equal(7, sequences[1].start_pos)
      assert.are.equal(11, sequences[1].end_pos)
      assert.are.equal('red', sequences[1].attrs.fg)
    end)
    
    it('should find multiple sequences', function()
      local text = '\27[31mRed\27[0m \27[32mGreen\27[0m'
      local sequences = parser.find_ansi_sequences(text)
      
      assert.are.equal(4, #sequences)
      assert.are.equal('red', sequences[1].attrs.fg)
      assert.is_true(sequences[2].attrs.reset)
      assert.are.equal('green', sequences[3].attrs.fg)
      assert.is_true(sequences[4].attrs.reset)
    end)
    
    it('should handle text without sequences', function()
      local text = 'Plain text without colors'
      local sequences = parser.find_ansi_sequences(text)
      
      assert.are.equal(0, #sequences)
    end)
  end)
end)