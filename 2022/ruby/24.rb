#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'matrixtools'
require_relative 'linalgtools'
require_relative 'test'

DIRECTION_SYMS = %i[> < ^ v]
WALL_SYM = :'#'
FLOOR_SYM = :'.'

def parse_io_line(line)
  line.chars.map(&:to_sym)
end

def parse_io(io)
  lines = io.readlines chomp: true
  map = lines.map { |line| parse_io_line line }
  shape = MatrixTools.shape map
  height, width = shape

  is = (0...height).to_a
  js = (0...width).to_a
  all_positions = is.product(js)

  start_i = 0
  start_j = js.find { |j| map[start_i][j] == FLOOR_SYM }
  start_position = [start_i, start_j]

  goal_i = height - 1
  goal_j = js.find { |j| map[goal_i][j] == FLOOR_SYM }
  goal_position = [goal_i, goal_j]

  nonwall_positions = all_positions.reject { |i, j| map[i][j] == WALL_SYM }
  tornado_positions = DIRECTION_SYMS.map do |direction|
    directed_tornado_positions = all_positions.select { |i, j| map[i][j] == direction }
    [directed_tornado_positions, direction]
  end

  [
    start_position,
    goal_position,
    {
      map: map,
      shape: shape,
      nonwall_positions: nonwall_positions,
      tornado_positions: tornado_positions
    }
  ]
end

def move_position(position, delta)
  LinAlg.add position, delta
end

def standardize_tornado_position(position, shape)
  position.zip(shape).map { |i, s| (i - 1) % (s - 2) + 1 }
end

def timed_delta(direction, minute)
  case direction
  when :> then [0, minute]
  when :< then [0, -minute]
  when :^ then [-minute, 0]
  when :v then [minute, 0]
  end
end

AGENT_DELTAS = [
  [-1, 0],
  [0, -1],
  [0, 0],
  [0, 1],
  [1, 0]
].freeze

def blur_positions(positions)
  positions.product(AGENT_DELTAS).map do |position, delta|
    move_position position, delta
  end.uniq
end

def timed_tornado_positions(minute, mapdata)
  mapdata[:tornado_positions].flat_map do |tornado_positions, direction|
    tornado_positions.map do |position|
      delta = timed_delta direction, minute
      position = move_position position, delta
      standardize_tornado_position position, mapdata[:shape]
    end
  end.uniq
end

def find_min_minute_step(positions, minute, mapdata)
  positions = blur_positions positions
  positions &= mapdata[:nonwall_positions]
  positions -= timed_tornado_positions minute + 1, mapdata

  [positions, minute + 1]
end

def find_min_minute(start_position, goal_position, minute, mapdata)
  positions = [start_position]

  until positions.include? goal_position
    return if positions.empty?

    positions, minute = find_min_minute_step positions, minute, mapdata
  end

  minute
end

def part1(io)
  start_position, goal_position, mapdata = parse_io io
  find_min_minute start_position, goal_position, 0, mapdata
end

def part2(io)
  start_position, goal_position, mapdata = parse_io io

  min_minute = find_min_minute start_position, goal_position, 0, mapdata
  min_minute = find_min_minute goal_position, start_position, min_minute, mapdata
  find_min_minute start_position, goal_position, min_minute, mapdata
end

example = <<~EOF
  #.######
  #>>.<^<#
  #.<..<<#
  #>v.><>#
  #<^v^^>#
  ######.#
EOF
Test.example StringIO.open(example) { |io| part1 io }, 18
Test.example StringIO.open(example) { |io| part2 io }, 54

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 242
Test.solution File.open(input) { |io| part2 io }, 720
