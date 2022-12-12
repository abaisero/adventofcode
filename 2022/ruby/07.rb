#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def add_size(sizes, cwd, size)
  (1 + cwd.length).times do |i|
    sizes[cwd[...i]] += size
  end
end

def parse_data(io)
  sizes = Hash.new(0)

  cwd = []
  io.each do |line|
    case line
    when %r{^\$ cd /$} then cwd.clear
    when /^\$ cd \.\.$/ then cwd.pop
    when /^\$ cd (\S+)$/ then cwd << Regexp.last_match(1)
    # when /^\$ ls$/
    # when /^dir \S+$/
    when /^(\d+) \S+$/ then add_size sizes, cwd, Regexp.last_match(1).to_i
    end
  end

  sizes
end

def part1(io)
  sizes = parse_data io
  sizes.values.select { |size| size <= 100_000 }.sum
end

def part2(io)
  sizes = parse_data io
  min_size = sizes[[]] - 40_000_000
  sizes.values.select { |size| size >= min_size }.min
end

example = <<~EOF
  $ cd /
  $ ls
  dir a
  14848514 b.txt
  8504156 c.dat
  dir d
  $ cd a
  $ ls
  dir e
  29116 f
  2557 g
  62596 h.lst
  $ cd e
  $ ls
  584 i
  $ cd ..
  $ cd ..
  $ cd d
  $ ls
  4060174 j
  8033020 d.log
  5626152 d.ext
  7214296 k
EOF
test_example StringIO.open(example) { |io| part1 io }, 95_437
test_example StringIO.open(example) { |io| part2 io }, 24_933_642

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
