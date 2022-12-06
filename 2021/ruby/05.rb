#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'
require_relative 'utils'

def parse_data(io)
  io.map do |line|
    match = line.match(/^(\d+),(\d+) -> (\d+),(\d+)$/)
    match.captures.map(&:to_i).each_slice(2).to_a
  end
end

def horizontal?(vent)
  vent[0][1] == vent[1][1]
end

def vertical?(vent)
  vent[0][0] == vent[1][0]
end

def diagonal?(vent)
  !horizontal?(vent) && !vertical?(vent)
end

def next_coordinate(from, to)
  # returns the next coordinate from x to y
  [
    next_value(from[0], to[0]),
    next_value(from[1], to[1])
  ]
end

def compute_coordinates(vent)
  coordinates = [vent[0]]
  coordinates << next_coordinate(coordinates.last, vent[1]) until coordinates.last == vent[1]
  coordinates
end

def make_field(vents)
  nrows = vents.flatten(1).map { |x, _| x }.max + 1
  ncols = vents.flatten(1).map { |_, y| y }.max + 1
  field = make_matrix(nrows, ncols) { 0 }

  coordinates = vents.flat_map { |vent| compute_coordinates(vent) }
  coordinates.each do |x, y|
    field[y][x] += 1
  end

  field
end

def count_overlaps(vents)
  field = make_field(vents)
  field.flatten.count { |n| n >= 2 }
end

def part1(io)
  vents = parse_data io
  vents = vents.reject { |vent| diagonal? vent }
  count_overlaps vents
end

def part2(io)
  vents = parse_data io
  count_overlaps vents
end

example = <<~EOF
  0,9 -> 5,9
  8,0 -> 0,8
  9,4 -> 3,4
  2,2 -> 2,1
  7,0 -> 7,4
  6,4 -> 2,0
  0,9 -> 2,9
  3,4 -> 1,4
  0,0 -> 8,8
  5,5 -> 8,2
EOF
test_example StringIO.open(example) { |io| part1 io }, 5
test_example StringIO.open(example) { |io| part2 io }, 12

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
