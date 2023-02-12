#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

PIXEL_TO_BIT = { '.' => 0, '#' => 1 }
BIT_TO_PIXEL = { 0 => '.', 1 => '#' }

def parse_data(io)
  lines = io.map(&:chomp).map { |line| line.each_char.map(&PIXEL_TO_BIT) }
  algorithm = lines.first
  image = lines[2..]
  [algorithm, image]
end

def expand_border(image, border_bit)
  width = image.first.length
  image = Array.new(2, Array.new(width, border_bit)) + image + Array.new(2, Array.new(width, border_bit))
  image.map { |line| Array.new(2, border_bit) + line + Array.new(2, border_bit) }
end

def enhance(algorithm, image, border_bit)
  image = expand_border image, border_bit

  indices = image.map { |line| line.each_cons(3).map { |x, y, z| 4 * x + 2 * y + z } }
  indices = indices.each_cons(3).map do |xline, yline, zline|
    xline.zip(yline, zline).map { |x, y, z| 64 * x + 8 * y + z }
  end

  image = indices.map { |line| line.map { |index| algorithm[index] } }
  border_bit = algorithm[256 * border_bit]

  [image, border_bit]
end

def part1(io)
  algorithm, image = parse_data io
  border_bit = 0
  2.times do
    image, border_bit = enhance algorithm, image, border_bit
  end
  image.flatten.sum
end

def part2(io)
  algorithm, image = parse_data io
  border_bit = 0
  50.times do
    image, border_bit = enhance algorithm, image, border_bit
  end
  image.flatten.sum
end

example = <<~EOF
  ..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..###..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#..#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#......#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.....####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.......##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#

  #..#.
  #....
  ##..#
  ..#..
  ..###
EOF
test_example StringIO.open(example) { |io| part1 io }, 35
test_example StringIO.open(example) { |io| part2 io }, 3351

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
