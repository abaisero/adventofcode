#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require 'test/unit/assertions'
include Test::Unit::Assertions

def read_data(io)
  io.each.map(&:strip)
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
  rucksacks = read_data io
  compartments = rucksacks.map { |rucksack| split_rucksack rucksack }
  share_items = compartments.map { |compartment1, compartment2| compartment1.chars & compartment2.chars }
  share_items.flatten.map { |item| compute_priority item }.sum
end

def part2(io)
  rucksacks = read_data io
  badges = rucksacks.each_slice(3).map { |r1, r2, r3| r1.chars & r2.chars & r3.chars }.flatten
  badges.map { |badge| compute_priority badge }.sum
end

example = StringIO.open \
  "vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw"
assert_equal part1(example), 157
example.rewind
assert_equal part2(example), 70

p part1 File.open('03.txt')
p part2 File.open('03.txt')
