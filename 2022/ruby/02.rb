#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def read_data(io)
  io.each.map { |line| line.split.map(&:to_sym) }
end

def score_shape(_x, y)
  score_hash = { rock: 1, paper: 2, scissors: 3 }
  score_hash[y]
end

def score_outcome(x, y)
  symbol_to_index = { rock: 0, paper: 1, scissors: 2 }
  score_matrix = [[3, 6, 0], [0, 3, 6], [6, 0, 3]]
  score_matrix[symbol_to_index[x]][symbol_to_index[y]]
end

def score(x, y)
  score_shape(x, y) + score_outcome(x, y)
end

def convert_strategy_to_moves_part1(strategy)
  conversion_hash = {
    A: :rock,
    B: :paper,
    C: :scissors,
    X: :rock,
    Y: :paper,
    Z: :scissors
  }
  strategy.flatten.map(&conversion_hash).each_slice(2).to_a
end

def part1(io)
  strategy = read_data io
  moves = convert_strategy_to_moves_part1 strategy
  moves.map { |x, y| score x, y }.sum
end

def convert_strategy_to_moves_part2(strategy)
  # convert strategy to categorical moves
  abc_hash = { A: 0, B: 1, C: 2 }
  xyz_hash = { X: -1, Y: 0, Z: 1 }
  moves = strategy.map do |x, y|
    xnew = abc_hash[x]
    ynew = abc_hash[x] + xyz_hash[y]
    [xnew, ynew % 3]
  end

  # convert categorical moves to symbolic moves
  symb_hash = { 0 => :rock, 1 => :paper, 2 => :scissors }
  moves.flatten.map(&symb_hash).each_slice(2).to_a
end

def part2(io)
  strategy = read_data io
  moves = convert_strategy_to_moves_part2 strategy
  moves.map { |x, y| score x, y }.sum
end

example = <<~EXAMPLE
  A Y
  B X
  C Z
EXAMPLE
test_example StringIO.open(example) { |io| part1 io }, 15
test_example StringIO.open(example) { |io| part2 io }, 12

input = '02.txt'
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
