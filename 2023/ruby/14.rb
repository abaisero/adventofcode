#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_io(io)
  lines = io.readlines chomp: true
  lines.map(&:chars)
end

def roll_row_left(row)
  rolled = Array.new row.length, '.'

  positions = []
  row.each_with_index do |tile, i|
    case tile
    when '.' then positions << i
    when 'O'
      positions << i
      rolled[positions.shift] = 'O'
    when '#'
      positions = []
      rolled[i] = '#'
    end
  end

  rolled
end

def roll_left(map)
  map.map { |row| roll_row_left row }
end

def roll_north(map)
  rolled = roll_left map.transpose
  rolled.transpose
end

def roll_south(map)
  rolled = roll_left map.transpose.map(&:reverse)
  rolled.map(&:reverse).transpose
end

def roll_east(map)
  rolled = roll_left map.map(&:reverse)
  rolled.map(&:reverse)
end

def roll_west(map)
  roll_left map
end

def roll(map, direction)
  case direction
  when :north then roll_north map
  when :south then roll_south map
  when :east then roll_east map
  when :west then roll_west map
  end
end

def row_load(row, weight)
  weight * row.count('O')
end

def total_load(map)
  loads = map.each_with_index.map do |row, i|
    weight = map.length - i
    row_load row, weight
  end
  loads.sum
end

def part1(io)
  map = parse_io io
  map = roll map, :north
  total_load map
end

CYCLE = %i[north west south east].freeze

def roll_cycle(map)
  CYCLE.each do |direction|
    map = roll map, direction
  end
  map
end

def shortcut(i, j, n)
  k = (n - i) / (j - i)
  j + (k - 1) * (j - i)
end

def roll_cycles(map, n)
  cache = {}

  i = 0
  while i < n
    cache[map] = i
    map = roll_cycle map
    i += 1

    i = shortcut cache[map], i, n if cache.key? map
  end

  map
end

def part2(io)
  map = parse_io io
  map = roll_cycles map, 1_000_000_000
  total_load map
end

example = <<~EOF
  O....#....
  O.OO#....#
  .....##...
  OO.#O....O
  .O.....O#.
  O.#..O.#.#
  ..O..#O..O
  .......O..
  #....###..
  #OO..#....
EOF
Test.example StringIO.open(example) { |io| part1 io }, 136
Test.example StringIO.open(example) { |io| part2 io }, 64

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 108_792
Test.solution File.open(input) { |io| part2 io }, 99_118
