#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'
require 'stringio'
require_relative 'test'

def make_horizontal_line(x0, x1, y)
  x0, x1 = [x0, x1].minmax
  (x0..x1).map { |x| [x, y] }
end

def make_vertical_line(x, y0, y1)
  y0, y1 = [y0, y1].minmax
  (y0..y1).map { |y| [x, y] }
end

def make_line(from, to)
  x0, y0 = from
  x1, y1 = to

  return make_horizontal_line(x0, x1, y1) if y0 == y1
  return make_vertical_line(x0, y0, y1) if x0 == x1

  raise
end

def make_occupacy(lines)
  occupacy = []
  lines.each do |line|
    line.each_cons(2) do |from, to|
      occupacy += make_line from, to
    end
  end
  occupacy.to_set
end

def parse_io_line(line)
  line.scan(/\d+/).map(&:to_i).each_slice(2)
end

def parse_io(io)
  lines = io.readlines chomp: true
  lines = lines.map { |line| parse_io_line line }
  make_occupacy lines
end

def next_sand_grain_candidates(grain)
  x, y = grain
  [[x, y + 1], [x - 1, y + 1], [x + 1, y + 1]]
end

def next_sand_grain(grain, occupacy)
  next_sand_grain_candidates(grain).find { |candidate| !occupacy.include? candidate }
end

def drop_grain(grain, occupacy, ymax)
  loop do
    break if grain[1] > ymax

    next_grain = next_sand_grain grain, occupacy
    break if next_grain.nil?

    grain = next_grain
  end

  grain
end

def num_grains1(source, occupacy)
  ymax = occupacy.map(&:last).max

  (0...).find do
    grain = drop_grain source, occupacy, ymax
    occupacy << grain
    grain[1] > ymax
  end
end

def part1(io)
  occupacy = parse_io io
  source = [500, 0]
  num_grains1 source, occupacy
end

def num_grains2(source, occupacy)
  ymax = occupacy.map(&:last).max

  xs = [source[0]]
  num_grains = 1
  (1...ymax + 2).each do |y|
    xs = xs.flat_map { |x| [x - 1, x, x + 1] }.uniq
    xs = xs.reject { |x| occupacy.include? [x, y] }
    num_grains += xs.length
  end
  num_grains
end

def part2(io)
  occupacy = parse_io io
  source = [500, 0]
  num_grains2 source, occupacy
end

example = <<~EOF
  498,4 -> 498,6 -> 496,6
  503,4 -> 502,4 -> 502,9 -> 494,9
EOF
Test.example StringIO.open(example) { |io| part1 io }, 24
Test.example StringIO.open(example) { |io| part2 io }, 93

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 719
Test.solution File.open(input) { |io| part2 io }, 23_390
