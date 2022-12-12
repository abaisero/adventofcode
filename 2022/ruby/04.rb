#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_data(io)
  io.map do |line|
    line.scan(/\d+/).map(&:to_i).each_slice(2).to_a
  end
end

def full_overlap?(xrange, yrange)
  (xrange.first >= yrange.first && xrange.last <= yrange.last) || (yrange.first >= xrange.first && yrange.last <= xrange.last)
end

def part1(io)
  ranges = parse_data io
  ranges.count { |xrange, yrange| full_overlap? xrange, yrange }
end

def partial_overlap?(xrange, yrange)
  xrange.first <= yrange.first && yrange.first <= xrange.last || yrange.first <= xrange.first && xrange.first <= yrange.last
end

def part2(io)
  ranges = parse_data io
  ranges.count { |xrange, yrange| partial_overlap? xrange, yrange }
end

example = <<~EOF
  2-4,6-8
  2-3,4-5
  5-7,7-9
  2-8,3-7
  6-6,4-6
  2-6,4-8
EOF
test_example StringIO.open(example) { |io| part1 io }, 2
test_example StringIO.open(example) { |io| part2 io }, 4

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
