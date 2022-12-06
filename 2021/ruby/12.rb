#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_data(io)
  io.map { |line| line.chomp.split('-') }
end

def start?(cave)
  cave == 'start'
end

def end?(cave)
  cave == 'end'
end

def small?(cave)
  cave[0].between? 'a', 'z'
end

def big?(cave)
  cave[0].between? 'A', 'Z'
end

def add_link(cavehash, from, to)
  return if end?(from) || start?(to)

  cavehash[from] = [] unless cavehash.include? from
  cavehash[from] << to
end

def make_cavehash(connections)
  cavehash = {}
  connections.each do |from, to|
    add_link cavehash, from, to
    add_link cavehash, to, from
  end
  cavehash
end

def find_paths1(cavehash, path = ['start'], paths = [])
  if end? path.last
    paths << path
    return
  end

  cavehash[path.last].each do |cave|
    next if small?(cave) && path.include?(cave)

    find_paths1 cavehash, path + [cave], paths
  end

  paths
end

def part1(io)
  connections = parse_data io
  cavehash = make_cavehash connections
  paths = find_paths1 cavehash
  paths.length
end

def already_double_visited_small(path)
  small_caves = path.select { |cave| small? cave }
  small_caves.length != small_caves.uniq.length
end

def find_paths2(cavehash, path = ['start'], paths = [])
  if end? path.last
    paths << path
    return
  end

  cavehash[path.last].each do |cave|
    next if small?(cave) && path.include?(cave) && already_double_visited_small(path)

    find_paths2 cavehash, path + [cave], paths
  end

  paths
end

def part2(io)
  connections = parse_data io
  cavehash = make_cavehash connections
  paths = find_paths2 cavehash
  paths.length
end

example = <<~EOF
  start-A
  start-b
  A-c
  A-b
  b-d
  A-end
  b-end
EOF
test_example StringIO.open(example) { |io| part1 io }, 10
test_example StringIO.open(example) { |io| part2 io }, 36

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
