# frozen_string_literal: true

require 'matrix'

def read_data(filename)
  File.readlines(filename).join.strip.split(',').map(&:to_i)
end

def part1(filename)
  positions = read_data filename
  crabs = (0..positions.max).map { |i| positions.count(i) }
  steps_to_cost = ->(steps) { steps }
  cost_matrix = Matrix.build(crabs.length) { |i, j| steps_to_cost.call (i - j).abs }
  crabs_vector = Matrix.column_vector crabs
  (cost_matrix * crabs_vector).min
end

def part2(filename)
  positions = read_data filename
  crabs = (0..positions.max).map { |i| positions.count(i) }
  steps_to_cost = ->(steps) { steps * (steps + 1) / 2 }
  cost_matrix = Matrix.build(crabs.length) { |i, j| steps_to_cost.call (i - j).abs }
  crabs_vector = Matrix.column_vector crabs
  (cost_matrix * crabs_vector).min
end

p part1 '07.example.txt'
p part1 '07.txt'
p part2 '07.example.txt'
p part2 '07.txt'
