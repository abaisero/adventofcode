#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_io_line(line)
  line.chars.map(&:to_i)
end

def parse_io(io)
  lines = io.readlines chomp: true
  lines.map { |line| parse_io_line line }
end

def visible_horizontal(trees)
  trees.map.with_index do |tree, i|
    i.zero? || # first
      trees[...i].max < tree || # higher than trees before
      i == trees.length - 1 || # last
      tree > trees[i + 1...].max # higher than trees after
  end
end

def visible_flat(trees)
  visible_h = trees.map { |row| visible_horizontal row }
  visible_v = trees.transpose.map { |row| visible_horizontal row }.transpose

  visible_h.flatten.zip(visible_v.flatten).map { |vh, vv| vh or vv }
end

def part1(io)
  trees = parse_io io
  visible_flat(trees).count(&:itself)
end

def score_tree_direction(height, trees)
  # index of first blocking tree
  index = trees.index { |tree| tree >= height }
  index.nil? ? trees.length : index + 1
end

def score_row_right(trees)
  trees.each_index.map do |i|
    score_tree_direction trees[i], trees[i + 1...]
  end
end

def score_trees(trees)
  scores_r = trees.map { |row| score_row_right row }
  scores_l = trees.map { |row| score_row_right(row.reverse).reverse }
  scores_u = trees.transpose.map { |row| score_row_right(row.reverse).reverse }.transpose
  scores_d = trees.transpose.map { |row| score_row_right row }.transpose

  flat_scores = scores_r.flatten.zip(scores_l.flatten, scores_u.flatten, scores_d.flatten)
  flat_scores = flat_scores.map { |rlud| rlud.reduce :* }
  flat_scores.each_slice(trees.first.length).to_a
end

def part2(io)
  trees = parse_io io
  scores = score_trees trees
  scores.map(&:max).max
end

example = <<~EOF
  30373
  25512
  65332
  33549
  35390
EOF
Test.example StringIO.open(example) { |io| part1 io }, 21
Test.example StringIO.open(example) { |io| part2 io }, 8

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 1681
Test.solution File.open(input) { |io| part2 io }, 201_684
