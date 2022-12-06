#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def read_data_stacks_line(stacks, line)
  crate_indices = (1...line.length).step(4)
  crates = crate_indices.map { |i| line[i] }
  crates_with_indices = crates.each.with_index(1).reject { |crate, _index| crate == ' ' }

  crates_with_indices.each do |crate, index|
    stacks[index] = [] unless stacks.key? index
    stacks[index].prepend crate
  end
end

def read_data_stacks(io)
  stacks = {}
  io.each do |line|
    next if /(\s+\d+)+/.match? line
    break if line.strip.empty?

    read_data_stacks_line(stacks, line)
  end
  stacks
end

def read_data_movements(io)
  io.map do |line|
    match = /^move (?<num>\d+) from (?<from>\d+) to (?<to>\d+)$/.match line
    [match['num'].to_i, match['from'].to_i, match['to'].to_i]
  end
end

def read_data(io)
  stacks = read_data_stacks io
  movements = read_data_movements io
  [stacks, movements]
end

def move_crates_part1(stacks, movements)
  movements.each do |num, from, to|
    num.times do
      stacks[to] << stacks[from].pop
    end
  end
end

def get_top_crates(stacks)
  stacks.keys.sort.map { |key| stacks[key].last }.join
end

def part1(io)
  stacks, movements = read_data io
  move_crates_part1 stacks, movements
  get_top_crates stacks
end

def move_crates_part2(stacks, movements)
  movements.each do |num, from, to|
    stacks[to].concat stacks[from].pop(num)
  end
end

def part2(io)
  stacks, movements = read_data io
  move_crates_part2 stacks, movements
  get_top_crates stacks
end

example = <<~EXAMPLE
      [D]
  [N] [C]
  [Z] [M] [P]
   1   2   3

  move 1 from 2 to 1
  move 3 from 1 to 3
  move 2 from 2 to 1
  move 1 from 1 to 2
EXAMPLE
test_example StringIO.open(example) { |io| part1 io }, 'CMZ'
test_example StringIO.open(example) { |io| part2 io }, 'MCD'

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
