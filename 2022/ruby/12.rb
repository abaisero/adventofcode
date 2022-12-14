#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'
require 'stringio'
require_relative 'linalgtools'
require_relative 'matrixtools'
require_relative 'test'

def parse_data(io)
  start = nil
  goal = nil

  map = io.map(&:chomp).map.with_index do |line, i|
    j = line.index('S')
    unless j.nil?
      start = [i, j]
      line[j] = 'a'
    end

    j = line.index('E')
    unless j.nil?
      goal = [i, j]
      line[j] = 'z'
    end

    line.chars
  end

  [map, start, goal]
end

def reconstruct_path(fromhash, start, goal)
  path = [goal]
  path <<= fromhash[path.last] until path.last == start
  path.reverse
end

def neighbors(map, node)
  deltas = [[-1, 0], [0, -1], [0, 1], [1, 0]]
  neighbors = apply_indices_deltas(*node, deltas).select do |i, j|
    valid_indices?(map, i, j) and map[i][j].ord <= map[node[0]][node[1]].ord + 1
  end
end

def astar(shape, start, goal, neighbors, cost, heuristic)
  nrows, ncols = shape
  gmatrix = make_matrix(nrows, ncols, Float::INFINITY)
  gmatrix[start[0]][start[1]] = 0
  hmatrix = make_matrix(nrows, ncols) { |i, j| heuristic.call [i, j], goal }

  fromhash = {}
  nodes = Set[start]
  until nodes.empty?
    node = nodes.min_by { |i, j| gmatrix[i][j] + hmatrix[i][j] }
    return reconstruct_path fromhash, start, goal if node == goal

    nodes.delete node

    i, j = node
    neighbors.call(node).each do |next_node|
      ni, nj = next_node
      g = gmatrix[i][j] + cost.call(node, next_node)
      next unless g < gmatrix[ni][nj]

      fromhash[next_node] = node
      gmatrix[ni][nj] = g
      nodes << next_node
    end
  end

  nil
end

def part1(io)
  map, start, goal = parse_data io
  shape = shape map
  neighbors = ->(node) { neighbors map, node }
  cost = ->(_node, _next_node) { 1 }
  heuristic = method(:l1_norm)
  path = astar shape, start, goal, neighbors, cost, heuristic
  path.length - 1
end

def part2(io)
  map, _, goal = parse_data io
  shape = shape map
  neighbors = ->(node) { neighbors map, node }
  cost = ->(_node, _next_node) { 1 }
  heuristic = method(:l1_norm)
  starts = all_indices(map).select { |i, j| map[i][j] == 'a' }
  paths = starts.map { |start| astar shape, start, goal, neighbors, cost, heuristic }.compact
  paths.map { |path| path.length - 1 }.min
end

example = <<~EOF
  Sabqponm
  abcryxxl
  accszExk
  acctuvwj
  abdefghi
EOF
test_example StringIO.open(example) { |io| part1 io }, 31
test_example StringIO.open(example) { |io| part2 io }, 29

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
