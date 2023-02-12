# frozen_string_literal: true

# Test module
module Test
  def self.example(value, expected)
    raise "Example error: #{value} (expected #{expected})" unless value == expected
  end

  def self.solution(value, expected = nil)
    puts value

    return if expected.nil?

    raise "Solution error: #{value} (expected #{expected})" unless value == expected
  end
end
