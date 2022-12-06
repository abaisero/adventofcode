# frozen_string_literal: true

def test_example(value, expected)
  raise "Example error: #{value} (expected #{expected})" unless value == expected
end
