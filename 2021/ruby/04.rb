#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_data(io)
  lines = io.map(&:chomp)
  numbers = lines.first.strip.split(',').map(&:to_i)
  boards = lines.drop(1).join(' ').split.map(&:to_i)
  boards = boards.each_slice(25).to_a
  [numbers, boards]
end

def update_board(board, number)
  board.map! { |x| x == number ? nil : x }
end

def bingo?(board)
  # checks if the board has achieved bingo
  board = board.each_slice(5).to_a
  lines = board + board.transpose
  lines.any? { |line| line.all?(&:nil?) }
end

def score(board, number)
  # computes the score of a board that achieved bingo with the number
  board.select(&:itself).sum * number
end

def part1(io)
  numbers, boards = parse_data io
  numbers.each do |number|
    boards.each do |board|
      update_board board, number
      return score board, number if bingo? board
    end
  end
end

def part2(io)
  numbers, boards = parse_data io
  numbers.each do |number|
    boards.each { |board| update_board board, number }
    return score boards.first, number if boards.one? && (bingo? boards.first)

    boards.reject! { |board| bingo? board }
  end
end

example = <<~EOF
  7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

  22 13 17 11  0
   8  2 23  4 24
  21  9 14 16  7
   6 10  3 18  5
   1 12 20 15 19

   3 15  0  2 22
   9 18 13 17  5
  19  8  7 25 23
  20 11 10 24  4
  14 21 16 12  6

  14 21 17 24  4
  10 16 15  9 19
  18  8 23 26 20
  22 11 13  6  5
   2  0 12  3  7
EOF
test_example StringIO.open(example) { |io| part1 io }, 4512
test_example StringIO.open(example) { |io| part2 io }, 1924

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
