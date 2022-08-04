#!/usr/bin/env ruby
# frozen_string_literal: true

def read_data(filename)
  File.foreach(filename).map { |line| line.strip.to_i }
end

def count_increasing_pairs(array)
  array.each_cons(2).count { |a, b| a < b }
end

def part1(filename)
  depths = read_data filename
  count_increasing_pairs depths
end

def part2(filename)
  depths = read_data filename
  depths = depths.each_cons(3).map { |x, y, z| x + y + z }
  count_increasing_pairs depths
end

p part1 '01.example.txt'
p part1 '01.txt'
p part2 '01.example.txt'
p part2 '01.txt'
