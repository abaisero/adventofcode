# frozen_string_literal: true

require_relative 'utils'

def read_data(filename)
  File.foreach(filename).map { |line| line.strip.split('').map(&:to_i) }
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

def part1(filename)
  matrix = read_data filename
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
  matrix.each_with_index do |row, i|
    row.each_with_index do |value, j|
      if (0..8).include? value
        basin_index -= 1
        traverse_step(matrix, i, j, basin_index)
      end
    end
  end
end

def part2(filename)
  matrix = read_data filename
  traverse matrix
  basins = matrix.flatten.reject(&:positive?).group_by(&:itself)
  basin_sizes = basins.map { |_k, v| v.length }.sort
  basin_sizes[-3] * basin_sizes[-2] * basin_sizes[-1]
end

p part1 '09.example.txt'
p part1 '09.txt'
p part2 '09.example.txt'
p part2 '09.txt'
