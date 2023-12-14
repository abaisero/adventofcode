#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'matrixtools'
require_relative 'linalgtools'
require_relative 'test'

def parse_io_line(line)
  line.chars
end

def parse_io(io)
  lines = io.readlines chomp: true
  lines.map { |line| parse_io_line line }
end

def find_start(map)
  i = map.find_index { |row| row.include? 'S' }
  j = map[i].find_index 'S'
  [i, j]
end

VALID_TILE_MOVEMENTS = {
  'S' => %i[U D L R],
  '|' => %i[U D],
  '-' => %i[L R],
  'L' => %i[U R],
  'J' => %i[U L],
  '7' => %i[D L],
  'F' => %i[D R]
}.freeze

VALID_TILE_CONNECTIONS = {
  U: ['S', '|', '7', 'F'],
  D: ['S', '|', 'L', 'J'],
  L: ['S', '-', 'L', 'F'],
  R: ['S', '-', 'J', '7']
}.freeze

def valid_movement?(map, indices, movement)
  delta = MOVEMENT_TO_DELTA[movement]
  indices2 = LinAlg.add indices, delta

  return false unless MatrixTools.valid_indices?(map, *indices2)

  tile1 = map.dig(*indices)
  tile2 = map.dig(*indices2)

  VALID_TILE_MOVEMENTS[tile1].include?(movement) && VALID_TILE_CONNECTIONS[movement].include?(tile2)
end

MOVEMENTS = %i[U D L R].freeze
MOVEMENT_TO_DELTA = {
  U: [-1, 0],
  D: [1, 0],
  L: [0, -1],
  R: [0, 1]
}.freeze

def remove_backtrack(deltas, delta)
  di, dj = delta
  delta = [-di, -dj]
  deltas - [delta]
end

def find_path(map)
  path = []
  path << find_start(map)

  movements = MOVEMENTS.select { |m| valid_movement? map, path.last, m }

  delta = MOVEMENT_TO_DELTA[movements.first]
  path << LinAlg.add(path.last, delta)

  loop do
    movements = MOVEMENTS.select { |m| valid_movement? map, path.last, m }
    deltas = movements.map { |m| MOVEMENT_TO_DELTA[m] }
    deltas = remove_backtrack deltas, delta
    raise unless deltas.length == 1

    delta, = deltas

    next_indices = LinAlg.add path.last, delta
    break if map.dig(*next_indices) == 'S'

    path << next_indices
  end

  path
end

def farthest_path_point(_map, path)
  path.length / 2
end

def part1(io)
  map = parse_io io
  path = find_path map
  farthest_path_point map, path
end

DELTA_TO_MOVEMENT = { [-1, 0] => :U, [1, 0] => :D, [0, -1] => :L, [0, 1] => :R }.freeze
STARTING_MOVEMENTS_TO_TILE = {
  %i[U U] => '|',
  %i[U L] => 'L',
  %i[U R] => 'J',
  %i[D D] => '|',
  %i[D L] => 'F',
  %i[D R] => '7',
  %i[L U] => '7',
  %i[L D] => 'J',
  %i[L L] => '-',
  %i[R U] => 'F',
  %i[R D] => 'L',
  %i[R R] => '-'
}.freeze

def clean_remove_junk(map, path)
  nrows, ncols = MatrixTools.shape map
  new_map = MatrixTools.make_matrix nrows, ncols, '.'
  path.each { |i, j| new_map[i][j] = map[i][j] }
  new_map
end

def clean_remove_starting(map, path)
  m1 = DELTA_TO_MOVEMENT[LinAlg.subtract(path[1], path[0])]
  m2 = DELTA_TO_MOVEMENT[LinAlg.subtract(path[0], path[-1])]
  i, j = path.first
  map[i][j] = STARTING_MOVEMENTS_TO_TILE[[m1, m2]]
  map
end

def clean(map, path)
  map = clean_remove_junk map, path
  clean_remove_starting map, path
end

def enclosed_area(map)
  map.map { |row| enclosed_area_row row }.sum
end

def enclosed_area_row(row)
  total = 0
  inside = false
  entered_tile = nil
  row.each do |tile|
    case tile
    when '|' then inside = !inside
    when 'L' then entered_tile = 'L'
    when 'J' then inside = !inside if entered_tile == 'F'
    when '7' then inside = !inside if entered_tile == 'L'
    when 'F' then entered_tile = 'F'
    when '.' then total += 1 if inside
    end
  end
  total
end

def part2(io)
  map = parse_io io
  path = find_path map
  map = clean map, path
  enclosed_area map
end

example = <<~EOF
  .....
  .S-7.
  .|.|.
  .L-J.
  .....
EOF
Test.example StringIO.open(example) { |io| part1 io }, 4
Test.example StringIO.open(example) { |io| part2 io }, 1

example = <<~EOF
  ..F7.
  .FJ|.
  SJ.L7
  |F--J
  LJ...
EOF
Test.example StringIO.open(example) { |io| part1 io }, 8
Test.example StringIO.open(example) { |io| part2 io }, 1

example = <<~EOF
  ...........
  .S-------7.
  .|F-----7|.
  .||.....||.
  .||.....||.
  .|L-7.F-J|.
  .|..|.|..|.
  .L--J.L--J.
  ...........
EOF
Test.example StringIO.open(example) { |io| part2 io }, 4

example = <<~EOF
  ..........
  .S------7.
  .|F----7|.
  .||OOOO||.
  .||OOOO||.
  .|L-7F-J|.
  .|II||II|.
  .L--JL--J.
  ..........
EOF
Test.example StringIO.open(example) { |io| part2 io }, 4

example = <<~EOF
  .F----7F7F7F7F-7....
  .|F--7||||||||FJ....
  .||.FJ||||||||L7....
  FJL7L7LJLJ||LJ.L-7..
  L--J.L7...LJS7F-7L7.
  ....F-J..F7FJ|L7L7L7
  ....L7.F7||L7|.L7L7|
  .....|FJLJ|FJ|F7|.LJ
  ....FJL-7.||.||||...
  ....L---J.LJ.LJLJ...
EOF
Test.example StringIO.open(example) { |io| part2 io }, 8

example = <<~EOF
  FF7FSF7F7F7F7F7F---7
  L|LJ||||||||||||F--J
  FL-7LJLJ||||||LJL-77
  F--JF--7||LJLJ7F7FJ-
  L---JF-JLJ.||-FJLJJ7
  |F|F-JF---7F7-L7L|7|
  |FFJF7L7F-JF7|JL---7
  7-L-JL7||F7|L7F-7F7|
  L.L7LFJ|||||FJL7||LJ
  L7JLJL-JLJLJL--JLJ.L
EOF
Test.example StringIO.open(example) { |io| part2 io }, 10

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 7145
Test.solution File.open(input) { |io| part2 io }, 445
