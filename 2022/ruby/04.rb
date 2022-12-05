#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require 'test/unit/assertions'
include Test::Unit::Assertions

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
  ranges.select { |ranges| full_overlap?(ranges) }.count
end

def partial_overlap?(ranges)
  f1, t1, f2, t2 = ranges
  f1 <= f2 && f2 <= t1 || f2 <= f1 && f1 <= t2
end

def part2(io)
  ranges = read_data io
  ranges.select { |ranges| partial_overlap?(ranges) }.count
end

example = StringIO.open \
  "2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8"
assert_equal part1(example), 2
example.rewind
assert_equal part2(example), 4

p part1 File.open('04.txt')
p part2 File.open('04.txt')
