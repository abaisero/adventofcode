#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_data(io)
  io.read.chomp
end

def find_first_uniq_index(signal, length)
  signal.each_char.each_cons(length).find_index { |chars| chars.length == chars.uniq.length } + length
end

def part1(io)
  signal = parse_data io
  find_first_uniq_index signal, 4
end

def part2(io)
  signal = parse_data io
  find_first_uniq_index signal, 14
end

example = 'mjqjpqmgbljsphdztnvjfqwrcgsmlb'
test_example StringIO.open(example) { |io| part1 io }, 7
test_example StringIO.open(example) { |io| part2 io }, 19

example = 'bvwbjplbgvbhsrlpgdmjqwftvncz'
test_example StringIO.open(example) { |io| part1 io }, 5
test_example StringIO.open(example) { |io| part2 io }, 23

example = 'nppdvjthqldpwncqszvftbrmjlhg'
test_example StringIO.open(example) { |io| part1 io }, 6
test_example StringIO.open(example) { |io| part2 io }, 23

example = 'nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg'
test_example StringIO.open(example) { |io| part1 io }, 10
test_example StringIO.open(example) { |io| part2 io }, 29

example = 'zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw'
test_example StringIO.open(example) { |io| part1 io }, 11
test_example StringIO.open(example) { |io| part2 io }, 26

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
