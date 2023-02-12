#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'data_stack'
require_relative 'test'

# Item
module Item
  def self.new(char)
    { char: char }
  end

  def self.priority(item)
    char = item[:char]
    case char
    when ('a'..'z') then char.ord - 'a'.ord + 1
    when ('A'..'Z') then char.ord - 'A'.ord + 27
    end
  end
end

# Collection
module Collection
  def self.new(objects)
    FrozenArray.new objects
  end

  def self.each(collection, &block)
    if block_given?
      collection.each(&block)
    else
      collection.each
    end
  end

  def self.intersection(collection, other_collection)
    Collection.new collection & other_collection
  end

  def self.one(collection)
    raise unless collection.one?

    collection.first
  end
end

def parse_io_line(line)
  line.chars.map { |item| Item.new item }
end

def parse_io(io)
  lines = io.readlines chomp: true
  rucksacks = lines.map do |line|
    items = parse_io_line line
    Collection.new items
  end
  Collection.new rucksacks
end

def rucksack_compartments(rucksack)
  size = Collection.each(rucksack).count
  compartments = Collection.each(rucksack).each_slice(size / 2).map do |compartment|
    Collection.new compartment
  end
  Collection.new compartments
end

def compute_shared_items(rucksacks)
  items = Collection.each(rucksacks).map do |rucksack|
    compartments = rucksack_compartments rucksack
    intersection = Collection.intersection(*compartments)
    Collection.one intersection
  end
  Collection.new items
end

def total_priority(items)
  Collection.each(items).map { |item| Item.priority item }.sum
end

def part1(io)
  rucksacks = parse_io io
  items = compute_shared_items rucksacks
  total_priority items
end

def split_rucksacks_into_groups(rucksacks, size)
  groups = Collection.each(rucksacks).each_slice(size).map do |rucksacks|
    Collection.new rucksacks
  end
  Collection.new groups
end

def group_badge(rucksack_group)
  badges = Collection.each(rucksack_group).reduce do |rucksack, other_rucksack|
    Collection.intersection rucksack, other_rucksack
  end
  Collection.one badges
end

def compute_badges(rucksacks)
  rucksack_groups = split_rucksacks_into_groups rucksacks, 3
  badges = Collection.each(rucksack_groups).map do |rucksack_group|
    group_badge rucksack_group
  end
  Collection.new badges
end

def part2(io)
  rucksacks = parse_io io
  badges = compute_badges rucksacks
  total_priority badges
end

example = <<~EOF
  vJrwpWtwJgWrhcsFMMfFFhFp
  jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
  PmmdzqPrVvPwwTWBwg
  wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
  ttgJtRGJQctTZtZT
  CrZsJsPPZsGzwwsLwLmpwMDw
EOF
Test.example StringIO.open(example) { |io| part1 io }, 157
Test.example StringIO.open(example) { |io| part2 io }, 70

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 8039
Test.solution File.open(input) { |io| part2 io }, 2510
