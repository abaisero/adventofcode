# frozen_string_literal: true

def read_data(filename)
  lines = File.readlines(filename).map(&:chomp)
  numbers = lines.first.strip.split(',').map(&:to_i)
  boards = lines.drop(1).join(' ').split.map(&:to_i)
  boards = boards.each_slice(25).to_a

  { numbers: numbers, boards: boards }
end

def update_board(board, number)
  board.map! { |board_number| board_number == number ? nil : board_number }
end

def bingo?(board)
  # checks if the board has achieved bingo
  board = board.each_slice(5).to_a
  lines = board + board.transpose
  lines.any? { |line| line.all?(&:nil?) }
end

def score(board, number)
  # computes the score of a board that achieved bingo with the number
  number * board.select(&:itself).sum
end

def part1(filename)
  data = read_data filename

  numbers = data[:numbers]
  boards = data[:boards]

  numbers.each do |number|
    boards.each do |board|
      update_board(board, number)
      return score(board, number) if bingo? board
    end
  end
end

def part2(filename)
  data = read_data filename

  numbers = data[:numbers]
  boards = data[:boards]

  numbers.each do |number|
    boards.each { |board| update_board(board, number) }
    return score(boards.first, number) if boards.one? && (bingo? boards.first)

    boards.reject! { |board| bingo? board }
  end
end

p part1 '04.example.txt'
p part1 '04.txt'
p part2 '04.example.txt'
p part2 '04.txt'
