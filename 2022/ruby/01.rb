#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require 'test/unit/assertions'
include Test::Unit::Assertions

def read_data(io)
  inventories = [[]]
  io.each do |line|
    case line
    when /^\d+$/ then inventories.last << line.to_i
    when /^$/ then inventories << []
    end
  end
  inventories
end

def max_k_calories(inventories, k)
  calories = inventories.map(&:sum)
  length_minus_k = calories.length - k
  calories.sort.reject.with_index { |_calory, idx| idx < length_minus_k }.sum
end

def part1(io)
  inventories = read_data io
  max_k_calories inventories, 1
end

def part2(io)
  inventories = read_data io
  max_k_calories inventories, 3
end

example = StringIO.open \
  "1000
2000
3000

4000

5000
6000

7000
8000
9000

10000"
assert_equal part1(example), 24_000
example.rewind
assert_equal part2(example), 45_000

p part1 File.open('01.txt')
p part2 File.open('01.txt')
