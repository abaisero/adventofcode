#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'
require 'stringio'
require_relative 'test'

def make_line_horizontal(x0, x1, y)
  x0, x1 = [x0, x1].minmax
  (x0..x1).map { |x| [x, y] }
end

def make_line_vertical(x, y0, y1)
  y0, y1 = [y0, y1].minmax
  (y0..y1).map { |y| [x, y] }
end

def make_line(from, to)
  x0, y0 = from
  x1, y1 = to

  return make_line_horizontal(x0, x1, y1) if y0 == y1
  return make_line_vertical(x0, y0, y1) if x0 == x1

  raise
end

def make_occupacy(lines)
  occupacy = Set[]
  lines.each do |line|
    line.each_cons(2) do |from, to|
      occupacy |= make_line from, to
    end
  end
  occupacy
end

def parse_data(io)
  lines = io.map { |line| line.scan(/\d+/).map(&:to_i).each_slice(2).to_a }
  occupacy = make_occupacy lines
end

def drop_sand_part1(occupacy, ymax)
  x = 500
  y = 0

  while true
    return nil if y > ymax

    unless occupacy.include? [x, y + 1]
      y += 1
      next
    end

    unless occupacy.include? [x - 1, y + 1]
      x -= 1
      y += 1
      next
    end

    unless occupacy.include? [x + 1, y + 1]
      x += 1
      y += 1
      next
    end

    return [x, y]
  end
end

def part1(io)
  occupacy = parse_data io
  ymax = occupacy.map(&:last).max

  (0...).find do
    position = drop_sand_part1 occupacy, ymax
    occupacy << position unless position.nil?
    position.nil?
  end
end

def drop_sand_part2(occupacy, ymax)
  x = 500
  y = 0

  return nil if occupacy.include? [x, y]

  while true
    return [x, y] if y == ymax + 1

    unless occupacy.include? [x, y + 1]
      y += 1
      next
    end

    unless occupacy.include? [x - 1, y + 1]
      x -= 1
      y += 1
      next
    end

    unless occupacy.include? [x + 1, y + 1]
      x += 1
      y += 1
      next
    end

    return [x, y]
  end
end

def part2(io)
  occupacy = parse_data io
  ymax = occupacy.map(&:last).max

  (0...).find do
    position = drop_sand_part2 occupacy, ymax
    occupacy << position unless position.nil?
    position.nil?
  end
end

example = <<~EOF
  498,4 -> 498,6 -> 496,6
  503,4 -> 502,4 -> 502,9 -> 494,9
EOF
test_example StringIO.open(example) { |io| part1 io }, 24
test_example StringIO.open(example) { |io| part2 io }, 93

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
