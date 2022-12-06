#!/usr/bin/env ruby
# frozen_string_literal: true

require 'matrix'
require 'stringio'
require_relative 'test'

def parse_data(io)
  io.read.split(',').map(&:to_i)
end

def compute_counts(positions)
  0.upto(positions.max).map { |i| positions.count(i) }
end

def compute_costs(crabs, cost_function)
  m = Matrix.build(crabs.length) { |i, j| cost_function.call (i - j).abs }
  v = Vector.elements crabs
  m * v
end

def compute_cost(positions, cost_function)
  counts = compute_counts positions
  compute_costs(counts, cost_function).min
end

def part1(io)
  positions = parse_data io
  compute_cost positions, ->(steps) { steps }
end

def part2(io)
  positions = parse_data io
  compute_cost positions, ->(steps) { steps * (steps + 1) / 2 }
end

example = '16,1,2,0,4,2,7,1,2,14'
test_example StringIO.open(example) { |io| part1 io }, 37
test_example StringIO.open(example) { |io| part2 io }, 168

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
