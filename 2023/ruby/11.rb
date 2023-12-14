#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'
require_relative 'matrixtools'
require_relative 'linalgtools'

def parse_io_line(line)
  line.chars
end

def parse_io(io)
  lines = io.readlines chomp: true
  lines.map { |line| parse_io_line line }
end

def empty_row?(row)
  row.all? { |tile| empty? tile }
end

def empty?(tile)
  tile == '.'
end

def galaxy?(tile)
  tile == '#'
end

def find_galaxies(map)
  galaxies = []
  MatrixTools.indices(map).each do |i, j|
    galaxies << [i, j] if galaxy?(map[i][j])
  end
  galaxies
end

def combinations(array)
  combinations = []
  (0...array.length).each do |i|
    ((i + 1)...array.length).each do |j|
      combinations << [array[i], array[j]]
    end
  end
  combinations
end

def distance(galaxy1, galaxy2)
  LinAlg.l1_dist(galaxy1, galaxy2)
end

def part1(io)
  count_distances io, 2
end

def part2(io)
  count_distances io, 1_000_000
end

def empty_rows(map)
  map.map.with_index { |row, i| i if empty_row?(row) }.compact
end

def empty_columns(map)
  empty_rows(map.transpose)
end

def count_distances(io, expansion)
  map = parse_io io
  galaxies = find_galaxies map
  distances = combinations(galaxies).map do |galaxy1, galaxy2|
    distance(galaxy1, galaxy2)
  end
  total = distances.sum

  empty_rows(map).each do |k|
    galaxies_before = galaxies.count { |i, _| i < k }
    galaxies_after = galaxies.count { |i, _| i > k }
    total += (expansion - 1) * galaxies_before * galaxies_after
  end

  empty_columns(map).each do |k|
    galaxies_before = galaxies.count { |_, j| j < k }
    galaxies_after = galaxies.count { |_, j| j > k }
    total += (expansion - 1) * galaxies_before * galaxies_after
  end

  total
end

example = <<~EOF
  ...#......
  .......#..
  #.........
  ..........
  ......#...
  .#........
  .........#
  ..........
  .......#..
  #...#.....
EOF
Test.example StringIO.open(example) { |io| part1 io }, 374
Test.example StringIO.open(example) { |io| count_distances io, 10 }, 1030
Test.example StringIO.open(example) { |io| count_distances io, 100 }, 8410

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 9_563_821
Test.solution File.open(input) { |io| part2 io }, 827_009_909_817
