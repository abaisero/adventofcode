#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_data(io)
  io.map { |line| line.chomp.each_char.map(&:to_i) }
end

def rotate(matrix, n = 1)
  case n % 4
  when 0 then matrix
  when 1 then matrix.transpose.map(&:reverse)
  when 2 then matrix.reverse.map(&:reverse)
  when 3 then matrix.transpose.reverse
  end
end

def visible_horizontal(trees)
  trees.map.with_index do |tree, i|
    i.zero? or # first
      trees[...i].max < tree or # higher than trees before
      i == trees.length - 1 or # last
      tree > trees[i + 1...].max # higher than trees after
  end
end

def visible(trees)
  num_cols = trees.first.length

  visible_h = trees.map { |row| visible_horizontal row }
  visible_v = trees.transpose.map { |row| visible_horizontal row }.transpose

  visible_flat = visible_h.flatten.zip(visible_v.flatten).map { |vh, vv| vh or vv }
  visible_flat.each_slice(num_cols).to_a
end

def count_true(nested_array)
  nested_array.flatten.count(&:itself)
end

def part1(io)
  trees = parse_data io
  count_true visible(trees)
end

def score_left_right(row)
  indices = (0...row.length)

  visible_left = Array.new(row.length, 0)
  indices.each do |i|
    next if i == 0

    visible_left[i] = i.times.map do |j|
      f, *rest, t = row[j..i]
      m = rest.max

      if m.nil?
        1
      elsif m >= t
        -1
      else
        i - j
      end
    end.max
  end
  visible_left
end

def score_horizontal(row)
  vleft = score_left_right(row)
  vright = score_left_right(row.reverse).reverse

  vleft.zip(vright).map { |l, r| l * r }
end

def part2(io)
  trees = parse_data io

  slr = trees.map { |row| score_horizontal(row) }
  srb = trees.transpose.map { |row| score_horizontal(row) }.transpose
  slr.flatten.zip(srb.flatten).map { |l, r| l * r }.max
end

example = <<~EOF
  30373
  25512
  65332
  33549
  35390
EOF
test_example StringIO.open(example) { |io| part1 io }, 21
test_example StringIO.open(example) { |io| part2 io }, 8

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
