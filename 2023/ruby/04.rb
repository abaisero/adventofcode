#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_io_line(line)
  _, numbers = line.split(':')
  winning, numbers = numbers.split('|')
  winning = winning.scan(/\d+/).map(&:to_i)
  numbers = numbers.scan(/\d+/).map(&:to_i)
  [winning, numbers]
end

def parse_io(io)
  lines = io.readlines chomp: true
  lines.map { |line| parse_io_line line }
end

def compute_winning_numbers(scratchcard)
  winning, numbers = scratchcard
  numbers.length - (numbers - winning).length
end

def compute_points(num_winning)
  num_winning.zero? ? 0 : 2**(num_winning - 1)
end

def part1(io)
  cards = parse_io io
  points = cards.map do |card|
    num_winning = compute_winning_numbers card
    compute_points num_winning
  end
  points.sum
end

def part2(io)
  cards = parse_io io
  copies = Array.new cards.length, 1

  copies.each_with_index do |num_copies, i|
    num_winning = compute_winning_numbers cards[i]
    (i + 1...i + 1 + num_winning).each do |j|
      copies[j] += num_copies
    end
  end

  copies.sum
end

example = <<~EOF
  Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
  Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
  Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
  Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
  Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
  Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
EOF
Test.example StringIO.open(example) { |io| part1 io }, 13
Test.example StringIO.open(example) { |io| part2 io }, 30

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 26_426
Test.solution File.open(input) { |io| part2 io }, 6_227_972
