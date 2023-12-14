#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'
require_relative 'matrixtools'
require_relative 'linalgtools'

def parse_io(io)
  io.readlines chomp: true
end

DELTAS = [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 0], [0, 1], [1, -1], [1, 0], [1, 1]].freeze

def make_part_indices(map, number, i, j)
  k = j + number.length - 1
  indices = (i - 1..i + 1).to_a.product((j - 1..k + 1).to_a)
  indices.select { |pi, pj| MatrixTools.valid_indices?(map, pi, pj) }
end

def symbol?(map, i, j)
  map[i][j] != '.' && map[i][j] !~ /\d/
end

def part1(io)
  map = parse_io io

  parts = {}
  map.each_with_index do |line, i|
    line.scan(/\d+/) do |n|
      j = Regexp.last_match.offset(0).first
      part_indices = make_part_indices(map, n, i, j)
      part = part_indices.any? { |pi, pj| symbol?(map, pi, pj) }
      parts[[i, j]] = n.to_i if part
    end
  end

  parts.values.sum
end

def part2(io)
  map = parse_io io

  gears = {}
  map.each_with_index do |line, i|
    line.scan(/\*/) do |_|
      j = Regexp.last_match.offset(0).first
      gears[[i, j]] = []
    end
  end

  map.each_with_index do |line, i|
    line.scan(/\d+/) do |n|
      j = Regexp.last_match.offset(0).first
      part_indices = make_part_indices(map, n, i, j)
      gears.each do |gear_indices, gear_array|
        gear_array << n.to_i if part_indices.include? gear_indices
      end
    end
  end

  ratios = gears.values.filter_map { |array| array.reduce(&:*) if array.length == 2 }
  ratios.sum
end

example = <<~EOF
  467..114..
  ...*......
  ..35..633.
  ......#...
  617*......
  .....+.58.
  ..592.....
  ......755.
  ...$.*....
  .664.598..
EOF
Test.example StringIO.open(example) { |io| part1 io }, 4361
Test.example StringIO.open(example) { |io| part2 io }, 467_835

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 544_664
Test.solution File.open(input) { |io| part2 io }, 84_495_585
