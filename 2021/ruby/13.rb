#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'
require_relative 'utils'

def parse_data(io)
  lines = io.map(&:chomp)
  index = lines.find_index(&:empty?)
  dots = lines[0...index].map { |line| line.split(',').map(&:to_i) }
  folds = lines[index + 1...]
  [dots, folds]
end

def perform_horizontal_fold(dots, fold_y)
  dots.map { |x, y| [x, y < fold_y ? y : 2 * fold_y - y] }
end

def perform_vertical_fold(dots, fold_x)
  dots.map { |x, y| [x < fold_x ? x : 2 * fold_x - x, y] }
end

def perform_fold(dots, fold)
  m = fold.match(/fold along ([xy])=(\d+)/)
  case m[1]
  when 'x' then perform_vertical_fold(dots, m[2].to_i)
  when 'y' then perform_horizontal_fold(dots, m[2].to_i)
  end
end

def render_dots(dots)
  nrows = dots.map { |_, y| y }.max + 1
  ncols = dots.map { |x, _| x }.max + 1
  matrix = make_matrix(nrows, ncols) { ' ' }
  dots.each do |x, y|
    matrix[y][x] = '#'
  end
  matrix.map(&:join).join("\n")
end

def part1(io)
  dots, folds = parse_data io
  dots = perform_fold(dots, folds.first)
  dots.uniq.length
end

def part2(io)
  dots, folds = parse_data io
  folds.each do |fold|
    dots = perform_fold(dots, fold)
  end
  render_dots dots.uniq
end

example = <<~EOF
  6,10
  0,14
  9,10
  0,3
  10,4
  4,11
  6,0
  6,12
  4,1
  0,13
  10,12
  3,4
  3,0
  8,4
  1,10
  2,14
  8,10
  9,0

  fold along y=7
  fold along x=5
EOF
test_example StringIO.open(example) { |io| part1 io }, 17
expected = <<~EOF
  #####
  #   #
  #   #
  #   #
  #####
EOF
test_example StringIO.open(example) { |io| part2 io }, expected.chomp

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
