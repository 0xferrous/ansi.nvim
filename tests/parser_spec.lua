local parser = require('ansi.parser')

describe('ANSI Parser', function()
  describe('parse_ansi_sequence', function()
    it('parses reset code', function()
      local attrs = parser.parse_ansi_sequence('0')
      assert.is_true(attrs.reset)
    end)

    it('parses foreground colors', function()
      local attrs = parser.parse_ansi_sequence('31')
      assert.are.equal('red', attrs.fg)
    end)

    it('parses background colors', function()
      local attrs = parser.parse_ansi_sequence('41')
      assert.are.equal('red', attrs.bg)
    end)

    it('parses text attributes', function()
      local attrs = parser.parse_ansi_sequence('1')
      assert.is_true(attrs.bold)

      local attrs2 = parser.parse_ansi_sequence('3')
      assert.is_true(attrs2.italic)

      local attrs3 = parser.parse_ansi_sequence('4')
      assert.is_true(attrs3.underline)
    end)

    it('parses combined codes', function()
      local attrs = parser.parse_ansi_sequence('1;31;42')
      assert.is_true(attrs.bold)
      assert.are.equal('red', attrs.fg)
      assert.are.equal('green', attrs.bg)
    end)

    it('parses foreground reset codes', function()
      local attrs = parser.parse_ansi_sequence('39')
      assert.are.equal('__reset__', attrs.fg)
    end)

    it('parses background reset codes', function()
      local attrs = parser.parse_ansi_sequence('49')
      assert.are.equal('__reset__', attrs.bg)
    end)

    it('parses combined codes with foreground reset', function()
      local attrs = parser.parse_ansi_sequence('33;41;39')
      assert.are.equal('__reset__', attrs.fg)
      assert.are.equal('red', attrs.bg)
    end)

    it('parses combined codes with background reset', function()
      local attrs = parser.parse_ansi_sequence('33;41;49')
      assert.are.equal('yellow', attrs.fg)
      assert.are.equal('__reset__', attrs.bg)
    end)
  end)

  describe('find_ansi_sequences', function()
    it('finds a single sequence', function()
      local text = 'Hello \27[31mworld\27[0m!'
      local sequences = parser.find_ansi_sequences(text)

      assert.are.equal(2, #sequences)
      assert.are.equal(7, sequences[1].start_pos)
      assert.are.equal(11, sequences[1].end_pos)
      assert.are.equal('red', sequences[1].attrs.fg)
      assert.is_true(sequences[2].attrs.reset)
    end)

    it('finds multiple sequences', function()
      local text = '\27[31mRed\27[0m \27[32mGreen\27[0m'
      local sequences = parser.find_ansi_sequences(text)

      assert.are.equal(4, #sequences)
      assert.are.equal('red', sequences[1].attrs.fg)
      assert.is_true(sequences[2].attrs.reset)
      assert.are.equal('green', sequences[3].attrs.fg)
      assert.is_true(sequences[4].attrs.reset)
    end)

    it('finds partial reset sequences', function()
      local text = '\27[33;41mYellow on red\27[39m default fg\27[49m default bg\27[0m'
      local sequences = parser.find_ansi_sequences(text)

      assert.are.equal(4, #sequences)
      assert.are.equal('yellow', sequences[1].attrs.fg)
      assert.are.equal('red', sequences[1].attrs.bg)
      assert.are.equal('__reset__', sequences[2].attrs.fg)
      assert.are.equal('__reset__', sequences[3].attrs.bg)
      assert.is_true(sequences[4].attrs.reset)
    end)

    it('handles text without sequences', function()
      local text = 'Plain text without colors'
      local sequences = parser.find_ansi_sequences(text)

      assert.are.equal(0, #sequences)
    end)
  end)
end)
