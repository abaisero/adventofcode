#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def read_data(io)
  io.each.map do |line|
    ranges = line.strip.split(',')
    ranges.map { |range| range.split('-').map(&:to_i) }.flatten
  end
end

def full_overlap?(ranges)
  f1, t1, f2, t2 = ranges
  (f1 >= f2 && t1 <= t2) || (f2 >= f1 && t2 <= t1)
end

def part1(io)
  ranges = read_data io
  ranges.count { |x| full_overlap? x }
end

def partial_overlap?(ranges)
  f1, t1, f2, t2 = ranges
  f1 <= f2 && f2 <= t1 || f2 <= f1 && f1 <= t2
end

def part2(io)
  ranges = read_data io
  ranges.count { |x| partial_overlap? x }
end

example = <<~EXAMPLE
  2-4,6-8
  2-3,4-5
  5-7,7-9
  2-8,3-7
  6-6,4-6
  2-6,4-8
EXAMPLE
test_example StringIO.open(example) { |io| part1 io }, 2
test_example StringIO.open(example) { |io| part2 io }, 4

input = '04.txt'
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
