#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_io1(io)
  lines = io.readlines chomp: true
  times, distances = lines
  times = times.scan(/\d+/).map(&:to_i)
  distances = distances.scan(/\d+/).map(&:to_i)
  [times, distances]
end

def parse_io2(io)
  lines = io.readlines chomp: true
  times, distances = lines
  time = times.scan(/\d+/).reduce(&:+).to_i
  distance = distances.scan(/\d+/).reduce(&:+).to_i
  [time, distance]
end

def solve_quadratic(a, b, c)
  sqrt = Math.sqrt(b**2 - 4 * a * c)
  min = (-b - sqrt) / (2 * a)
  max = (-b + sqrt) / (2 * a)
  [min, max]
end

def compute_num_solutions(time, distance)
  min, max = solve_quadratic 1, -time, distance

  # to correctly consider the inequality, instead of doing ceil, we do +1 and floor
  min = (min + 1).floor
  # to correctly consider the inequality, instead of doing floor, we do -1 and ceil
  max = (max - 1).ceil

  max - min + 1
end

def part1(io)
  times, distances = parse_io1 io
  num_solutions = times.zip(distances).map { |time, distance| compute_num_solutions time, distance }
  num_solutions.reduce(&:*)
end

def part2(io)
  time, distance = parse_io2 io
  compute_num_solutions time, distance
end

example = <<~EOF
  Time:      7  15   30
  Distance:  9  40  200
EOF
Test.example StringIO.open(example) { |io| part1 io }, 288
Test.example StringIO.open(example) { |io| part2 io }, 71_503

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 2_269_432
Test.solution File.open(input) { |io| part2 io }, nil
