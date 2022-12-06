#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

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

example = <<~EXAMPLE
  1000
  2000
  3000

  4000

  5000
  6000

  7000
  8000
  9000

  10000
EXAMPLE
test_example StringIO.open(example) { |io| part1 io }, 24_000
test_example StringIO.open(example) { |io| part2 io }, 45_000

input = '01.txt'
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
