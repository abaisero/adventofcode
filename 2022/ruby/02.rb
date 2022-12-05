#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require 'test/unit/assertions'
include Test::Unit::Assertions

def read_data(io)
  io.each.map { |line| line.split.map(&:to_sym) }
end

def shape_score(moves)
  shapescore_hash = { rock: 1, paper: 2, scissors: 3 }
  moves.map { |_m1, m2| shapescore_hash[m2] }.sum
end

def outcome_score(moves)
  outcomescore_hash = {
    %i[rock rock] => 3,
    %i[rock paper] => 6,
    %i[rock scissors] => 0,
    %i[paper rock] => 0,
    %i[paper paper] => 3,
    %i[paper scissors] => 6,
    %i[scissors rock] => 6,
    %i[scissors paper] => 0,
    %i[scissors scissors] => 3
  }
  moves.map(&outcomescore_hash).sum
end

def score(moves)
  shape_score(moves) + outcome_score(moves)
end

def convert_strategy_to_moves_1(strategy)
  conversion_hash = {
    %i[A X] => %i[rock rock],
    %i[A Y] => %i[rock paper],
    %i[A Z] => %i[rock scissors],
    %i[B X] => %i[paper rock],
    %i[B Y] => %i[paper paper],
    %i[B Z] => %i[paper scissors],
    %i[C X] => %i[scissors rock],
    %i[C Y] => %i[scissors paper],
    %i[C Z] => %i[scissors scissors]
  }
  strategy.map(&conversion_hash)
end

def part1(io)
  strategy = read_data io
  moves = convert_strategy_to_moves_1 strategy
  score moves
end

def convert_strategy_to_moves_2(strategy)
  conversion_hash = {
    %i[A X] => %i[rock scissors],
    %i[A Y] => %i[rock rock],
    %i[A Z] => %i[rock paper],
    %i[B X] => %i[paper rock],
    %i[B Y] => %i[paper paper],
    %i[B Z] => %i[paper scissors],
    %i[C X] => %i[scissors paper],
    %i[C Y] => %i[scissors scissors],
    %i[C Z] => %i[scissors rock]
  }
  strategy.map(&conversion_hash)
end

def part2(io)
  strategy = read_data io
  moves = convert_strategy_to_moves_2 strategy
  score moves
end

example = StringIO.open \
  "A Y
B X
C Z"
assert_equal part1(example), 15
example.rewind
assert_equal part2(example), 12

p part1 File.open('02.txt')
p part2 File.open('02.txt')
