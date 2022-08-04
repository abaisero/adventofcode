#!/usr/bin/env ruby
# frozen_string_literal: true

require 'matrix'

def read_data(filename)
  File.readlines(filename).join.strip.split(',').map(&:to_i)
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

def part1(filename)
  positions = read_data filename
  compute_cost positions, ->(steps) { steps }
end

def part2(filename)
  positions = read_data filename
  compute_cost positions, ->(steps) { steps * (steps + 1) / 2 }
end

p part1 '07.example.txt'
p part1 '07.txt'
p part2 '07.example.txt'
p part2 '07.txt'
