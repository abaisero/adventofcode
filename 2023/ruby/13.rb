#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_io(io)
  patterns = [[]]

  io.each do |line|
    row = line.chomp.chars

    if row.empty?
      patterns << []
    else
      patterns.last << row
    end
  end

  patterns
end

def pattern_error(pattern1, pattern2)
  pattern1 = pattern1.flatten
  pattern2 = pattern2.flatten
  pattern1.zip(pattern2).count { |tile1, tile2| tile1 != tile2 }
end

def reflection_error(pattern, n)
  top = pattern[...n].reverse
  bottom = pattern[n...]

  length = [top.length, bottom.length].min
  pattern_error top[...length], bottom[...length]
end

def count_rows_above_reflection(pattern, target_error)
  (1...pattern.length).find { |n| reflection_error(pattern, n) == target_error }
end

def summarize(pattern, target_error)
  i = count_rows_above_reflection pattern, target_error

  return 100 * i unless i.nil?

  count_rows_above_reflection pattern.transpose, target_error
end

def part1(io)
  patterns = parse_io io
  patterns.map { |pattern| summarize pattern, 0 }.sum
end

def part2(io)
  patterns = parse_io io
  patterns.map { |pattern| summarize pattern, 1 }.sum
end

example = <<~EOF
  #.##..##.
  ..#.##.#.
  ##......#
  ##......#
  ..#.##.#.
  ..##..##.
  #.#.##.#.

  #...##..#
  #....#..#
  ..##..###
  #####.##.
  #####.##.
  ..##..###
  #....#..#
EOF
Test.example StringIO.open(example) { |io| part1 io }, 405
Test.example StringIO.open(example) { |io| part2 io }, 400

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 34_911
Test.solution File.open(input) { |io| part2 io }, 33_183
