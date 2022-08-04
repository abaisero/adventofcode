#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'utils'

def read_data(filename)
  File.foreach(filename).map do |line|
    m = line.strip.match(/^(?<x1>\d+),(?<y1>\d+) -> (?<x2>\d+),(?<y2>\d+)$/)
    from = [m[:x1].to_i, m[:y1].to_i]
    to = [m[:x2].to_i, m[:y2].to_i]
    [from, to]
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

def part1(filename)
  vents = read_data filename
  vents = vents.reject { |vent| diagonal? vent }
  count_overlaps vents
end

def part2(filename)
  vents = read_data filename
  count_overlaps vents
end

p part1 '05.example.txt'
p part1 '05.txt'
p part2 '05.example.txt'
p part2 '05.txt'
