#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_data(io)
  io.map(&:chomp)
end

def part1(io)
  parse_data io
end

def part2(io)
  parse_data io
end

example = <<~EOF
EOF
test_example StringIO.open(example) { |io| part1 io }, nil
test_example StringIO.open(example) { |io| part2 io }, nil

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
