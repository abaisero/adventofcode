#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_data(io)
  io.map(&:chomp)
end

def split_rucksack(rucksack)
  rucksack.chars.each_slice(rucksack.length / 2).map(&:join)
end

def compute_priority(item)
  case item
  when /^[[:lower:]]$/ then item.ord - 'a'.ord + 1
  when /^[[:upper:]]$/ then item.ord - 'A'.ord + 27
  end
end

def compute_priorities(items)
  items.map { |item| compute_priority item }
end

def part1(io)
  rucksacks = parse_data io
  compartments = rucksacks.map { |rucksack| split_rucksack rucksack }
  share_items = compartments.map { |compartment1, compartment2| compartment1.chars & compartment2.chars }
  share_items.flatten.map { |item| compute_priority item }.sum
end

def part2(io)
  rucksacks = parse_data io
  badges = rucksacks.each_slice(3).map { |r1, r2, r3| r1.chars & r2.chars & r3.chars }.flatten
  badges.map { |badge| compute_priority badge }.sum
end

example = <<~EOF
  vJrwpWtwJgWrhcsFMMfFFhFp
  jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
  PmmdzqPrVvPwwTWBwg
  wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
  ttgJtRGJQctTZtZT
  CrZsJsPPZsGzwwsLwLmpwMDw
EOF
test_example StringIO.open(example) { |io| part1 io }, 157
test_example StringIO.open(example) { |io| part2 io }, 70

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
