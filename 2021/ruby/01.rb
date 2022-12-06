#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_data(io)
  io.map(&:to_i)
end

def count_increasing_pairs(array)
  array.each_cons(2).count { |a, b| a < b }
end

def part1(io)
  depths = parse_data io
  count_increasing_pairs depths
end

def part2(io)
  depths = parse_data io
  depths = depths.each_cons(3).map { |x, y, z| x + y + z }
  count_increasing_pairs depths
end

example = <<~EOF
  199
  200
  208
  210
  200
  207
  240
  269
  260
  263
EOF
test_example StringIO.open(example) { |io| part1 io }, 7
test_example StringIO.open(example) { |io| part2 io }, 5

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
