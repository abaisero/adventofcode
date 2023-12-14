#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_io_line(line)
  line.scan(/-?\d+/).map(&:to_i)
end

def parse_io(io)
  lines = io.readlines chomp: true
  lines.map { |line| parse_io_line line }
end

def compute_subhistory(history)
  history.each_cons(2).map { |x, y| y - x }
end

def predict(history)
  return 0 if history.all?(&:zero?)

  subhistory = compute_subhistory history
  history.last + predict(subhistory)
end

def part1(io)
  histories = parse_io io
  predictions = histories.map { |history| predict history }
  predictions.sum
end

def part2(io)
  histories = parse_io io
  predictions = histories.map { |history| predict history.reverse }
  predictions.sum
end

example = <<~EOF
  0 3 6 9 12 15
  1 3 6 10 15 21
  10 13 16 21 30 45
EOF
Test.example StringIO.open(example) { |io| part1 io }, 114
Test.example StringIO.open(example) { |io| part2 io }, 2

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 1_666_172_641
Test.solution File.open(input) { |io| part2 io }, 933
