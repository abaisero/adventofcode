#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'
require_relative 'utils'

def parse_data(io)
  io.map { |line| line.chomp.each_char.map(&:to_i) }
end

def matrix_lowpoints(matrix)
  lowpoints1 = matrix.map { |array| array_lowpoints array }
  lowpoints2 = matrix.transpose.map { |array| array_lowpoints array }.transpose

  lowpoints1.zip(lowpoints2).map do |array1, array2|
    array1.zip(array2).map { |l1, l2| l1 && l2 }
  end
end

def array_lowpoints(array)
  [array[0] < array[1]] + array.each_cons(3).map { |x, y, z| x > y and y < z } + [array[-2] > array[-1]]
end

def part1(io)
  matrix = parse_data io
  lowpoints = matrix_lowpoints matrix
  matrix.flatten.zip(lowpoints.flatten).select { |_d, l| l }.map { |d, _l| d + 1 }.sum
end

def neighbor_indices(index_i, index_j)
  deltas = [[-1, 0], [0, -1], [1, 0], [0, 1]]
  apply_indices_deltas(index_i, index_j, deltas)
end

def valid_neighbor_indices(matrix, index_i, index_j)
  neighbor_indices(index_i, index_j).select { |i, j| valid_indices?(matrix, i, j) }
end

def traverse_step(matrix, index_i, index_j, basin_id)
  matrix[index_i][index_j] = basin_id
  valid_neighbor_indices(matrix, index_i, index_j).each do |i, j|
    traverse_step(matrix, i, j, basin_id) if matrix[i][j] != 9 && matrix[i][j] != basin_id
  end
end

def traverse(matrix)
  basin_index = 0
  matrix.each.with_index do |row, i|
    row.each.with_index do |value, j|
      if value.between?(0, 8)
        basin_index -= 1
        traverse_step(matrix, i, j, basin_index)
      end
    end
  end
end

def part2(io)
  matrix = parse_data io
  traverse matrix
  basins = matrix.flatten.reject(&:positive?).group_by(&:itself)
  basin_sizes = basins.map { |_k, v| v.length }.sort
  basin_sizes[-3] * basin_sizes[-2] * basin_sizes[-1]
end

example = <<~EOF
  2199943210
  3987894921
  9856789892
  8767896789
  9899965678
EOF
test_example StringIO.open(example) { |io| part1 io }, 15
test_example StringIO.open(example) { |io| part2 io }, 1134

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
