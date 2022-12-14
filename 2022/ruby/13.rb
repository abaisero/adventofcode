#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require 'yaml'
require_relative 'test'

def parse_data(io)
  io.map { |line| YAML.safe_load line }.compact
end

def compare_integers(x, y)
  x <=> y
end

def compare_lists(x, y)
  x.zip(y) do |a, b|
    next if a == b

    return 1 if b.nil?

    return compare_packets a, b
  end

  x.length <=> y.length
end

def compare_packets(x, y)
  return compare_integers x, y if x.is_a?(Integer) and y.is_a?(Integer)

  x = [x] if x.is_a?(Integer)
  y = [y] if y.is_a?(Integer)
  compare_lists x, y
end

def correct_order?(x, y)
  compare_packets(x, y) == -1
end

def part1(io)
  packets = parse_data io
  indices = packets.each_slice(2).with_index(1).filter_map { |packets, index| index if correct_order?(*packets) }
  indices.sum
end

def part2(io)
  packets = parse_data io
  divider_packets = [[[2]], [[6]]]
  packets += divider_packets
  packets.sort! { |x, y| compare_packets x, y }
  indices = divider_packets.map { |packet| packets.index(packet) + 1 }
  indices.reduce(1, :*)
end

example = <<~EOF
  [1,1,3,1,1]
  [1,1,5,1,1]

  [[1],[2,3,4]]
  [[1],4]

  [9]
  [[8,7,6]]

  [[4,4],4,4]
  [[4,4],4,4,4]

  [7,7,7,7]
  [7,7,7]

  []
  [3]

  [[[]]]
  [[]]

  [1,[2,[3,[4,[5,6,7]]]],8,9]
  [1,[2,[3,[4,[5,6,0]]]],8,9]
EOF
test_example StringIO.open(example) { |io| part1 io }, 13
test_example StringIO.open(example) { |io| part2 io }, 140

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
