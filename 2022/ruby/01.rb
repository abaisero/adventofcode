#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'data_stack'
require_relative 'test'

# Item
module Item
  def self.new(calories)
    { calories: calories }
  end

  def self.calories(item)
    item[:calories]
  end
end

# Inventory
module Inventory
  def self.new(items = nil)
    FrozenArray.new items
  end

  def self.add_item(inventory, item)
    FrozenArray.append inventory, item
  end

  def self.each(inventories)
    inventories
  end
end

# InventoryCollection
module InventoryCollection
  def self.new(inventories = nil)
    FrozenArray.new inventories
  end

  def self.empty?(inventories)
    inventories.empty?
  end

  def self.add_inventory(inventories, inventory)
    FrozenArray.append inventories, inventory
  end

  def self.pop_inventory(inventories)
    FrozenArray.pop inventories
  end

  def self.each(inventories)
    inventories
  end
end

def parse_io_line(line)
  Item.new(line.to_i) unless line.empty?
end

def parse_io(io)
  lines = io.readlines chomp: true
  items = lines.map { |line| parse_io_line line }

  inventories = items.chunk(&:nil?).filter_map do |not_an_inventory, inventory|
    inventory unless not_an_inventory
  end
  inventories = inventories.map { |inventory| Inventory.new inventory }
  InventoryCollection.new inventories
end

def inventory_calories(inventory)
  Inventory.each(inventory).map { |item| Item.calories item }.sum
end

def calories(inventories)
  InventoryCollection.each(inventories).map do |inventory|
    inventory_calories inventory
  end
end

def part1(io)
  inventories = parse_io io
  calories(inventories).max
end

def part2(io)
  inventories = parse_io io
  calories(inventories).max(3).sum
end

example = <<~EOF
  1000
  2000
  3000

  4000

  5000
  6000

  7000
  8000
  9000

  10000
EOF
Test.example StringIO.open(example) { |io| part1 io }, 24_000
Test.example StringIO.open(example) { |io| part2 io }, 45_000

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 69_836
Test.solution File.open(input) { |io| part2 io }, 207_968
