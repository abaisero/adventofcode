#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'
require 'stringio'
require_relative 'linalgtools'
require_relative 'matrixtools'
require_relative 'test'

def parse_io_line(line)
  line.chars
end

def parse_io(io)
  lines = io.readlines chomp: true

  map = lines.map { |line| parse_io_line line }
  start = MatrixTools.find_index(map) { |i, j| map[i][j] == 'S' }
  goal = MatrixTools.find_index(map) { |i, j| map[i][j] == 'E' }
  map[start[0]][start[1]] = 'a'
  map[goal[0]][goal[1]] = 'z'

  [map, start, goal]
end

def steppable?(from, to, map)
  map.dig(*from).ord >= map.dig(*to).ord - 1
end

def valid_neighbor?(from, to, map)
  MatrixTools.valid_indices?(map, *to) && steppable?(from, to, map)
end

DELTAS = [[-1, 0], [0, -1], [0, 1], [1, 0]].freeze

def neighbors(map, node)
  candidates = DELTAS.map { |delta| LinAlg.add node, delta }
  candidates.select { |candidate| valid_neighbor? node, candidate, map }
end

def step(positions, map)
  next_positions = Set[]
  positions.each do |position|
    next_positions.merge neighbors(map, position)
  end
  next_positions
end

def path_length(starting_positions, goal_position, map)
  positions = Set.new
  boundary = Set.new starting_positions
  (1...).find do
    boundary = step boundary, map
    boundary -= positions
    positions += boundary
    boundary.include? goal_position
  end
end

def part1(io)
  map, starting_position, goal_position = parse_io io
  starting_positions = [starting_position]
  path_length starting_positions, goal_position, map
end

def part2(io)
  map, _, goal_position = parse_io io
  starting_positions = MatrixTools.indices(map).select { |i, j| map[i][j] == 'a' }
  path_length starting_positions, goal_position, map
end

example = <<~EOF
  Sabqponm
  abcryxxl
  accszExk
  acctuvwj
  abdefghi
EOF
Test.example StringIO.open(example) { |io| part1 io }, 31
Test.example StringIO.open(example) { |io| part2 io }, 29

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 361
Test.solution File.open(input) { |io| part2 io }, 354
