#!/usr/bin/env ruby
# frozen_string_literal: true

def read_data(filename)
  lines = File.readlines(filename).map(&:chomp)
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

def part1(filename)
  numbers, boards = read_data filename
  numbers.each do |number|
    boards.each do |board|
      update_board board, number
      return score board, number if bingo? board
    end
  end
end

def part2(filename)
  numbers, boards = read_data filename
  numbers.each do |number|
    boards.each { |board| update_board board, number }
    return score boards.first, number if boards.one? && (bingo? boards.first)

    boards.reject! { |board| bingo? board }
  end
end

p part1 '04.example.txt'
p part1 '04.txt'
p part2 '04.example.txt'
p part2 '04.txt'
