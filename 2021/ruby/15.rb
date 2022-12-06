#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'
require 'stringio'
require_relative 'test'
require_relative 'utils'

def parse_data(io)
  io.map { |line| line.chomp.each_char.map(&:to_i) }
end

def heuristic(matrix, index_i, index_j)
  max_i = matrix.length - 1
  max_j = matrix.first.length - 1
  max_i - index_i + max_j - index_j
end

def reconstruct_path(fromhash, start, goal)
  path = [goal]
  path <<= fromhash[path.last] until path.last == start
  path.reverse
end

def neighbors(risks, node)
  deltas = [[-1, 0], [0, -1], [0, 1], [1, 0]]
  apply_indices_deltas(*node, deltas).select { |i, j| valid_indices?(risks, i, j) }
end

def astar(risks)
  nrows = risks.length
  ncols = risks.first.length
  start = [0, 0]
  goal = [nrows - 1, ncols - 1]

  gmatrix = make_matrix(nrows, ncols) { Float::INFINITY }
  gmatrix[0][0] = 0
  hmatrix = make_matrix(nrows, ncols) { |i, j| heuristic risks, i, j }

  fromhash = {}
  nodes = Set[start]

  until nodes.empty?
    node = nodes.to_a.min_by { |i, j| gmatrix[i][j] + hmatrix[i][j] }
    return reconstruct_path fromhash, start, goal if node == goal

    nodes.delete node
    i, j = node

    neighbors(risks, node).each do |next_node|
      ni, nj = next_node
      g = gmatrix[i][j] + risks[ni][nj]
      next unless g < gmatrix[ni][nj]

      fromhash[next_node] = node
      gmatrix[ni][nj] = g
      nodes <<= next_node
    end
  end

  raise 'astar found possible path'
end

def pp_path(risks, path)
  pmatrix = risks.map { |row| row.map(&:to_s) }
  path.each do |i, j|
    pmatrix[i][j] = '.'
  end
  puts pmatrix.map(&:join).join("\n")
end

def pathrisk(risks, path)
  path[1...].map { |i, j| risks[i][j] }.sum
end

def part1(io)
  risks = parse_data io
  path = astar risks
  # pp_path risks, path
  pathrisk risks, path
end

def bound_risk(risk)
  # bounds risks between 1 and 9
  (risk - 1) % 9 + 1
end

def full_riskmap(risks)
  nrows = risks.length
  ncols = risks.first.length
  make_matrix(5 * nrows, 5 * ncols) do |i, j|
    bound_risk risks[i % nrows][j % ncols] + i / nrows + j / ncols
  end
end

def part2(io)
  risks = parse_data io
  risks = full_riskmap risks
  path = astar risks
  # pp_path risks, path
  pathrisk risks, path
end

example = <<~EOF
  1163751742
  1381373672
  2136511328
  3694931569
  7463417111
  1319128137
  1359912421
  3125421639
  1293138521
  2311944581
EOF
test_example StringIO.open(example) { |io| part1 io }, 40
test_example StringIO.open(example) { |io| part2 io }, 315

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
