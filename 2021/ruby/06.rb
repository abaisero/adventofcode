#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_data(io)
  io.read.split(',').map(&:to_i)
end

def initial_fishcounts(fish)
  (0..8).map { |n| fish.count n }
end

def updated_fishcounts(fishcounts)
  fishcounts = fishcounts.rotate
  fishcounts[6] += fishcounts.last
  fishcounts
end

def nfish_after_ndays(fish, ndays)
  fishcounts = initial_fishcounts fish
  ndays.times do
    fishcounts = updated_fishcounts fishcounts
  end
  fishcounts.sum
end

def part1(io)
  fish = parse_data io
  nfish_after_ndays fish, 80
end

def part2(io)
  fish = parse_data io
  nfish_after_ndays fish, 256
end

example = '3,4,3,1,2'
test_example StringIO.open(example) { |io| part1 io }, 5934
test_example StringIO.open(example) { |io| part2 io }, 26_984_457_539

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
