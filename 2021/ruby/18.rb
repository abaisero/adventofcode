#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require 'yaml'
require_relative 'test'

# A module to handle multi-index operations for nested arrays
module Mindex
  module_function

  def first(array)
    case array
    when Integer then []
    when Array then [0] + first(array[0])
    else raise 'invalid array'
    end
  end

  def last(array)
    case array
    when Integer then []
    when Array then [1] + last(array[1])
    else raise 'invalid array'
    end
  end

  def get(array, mindex)
    i = mindex.first
    mindex.length == 1 ? array[i] : get(array[i], mindex[1...])
  end

  def set(array, mindex, value)
    i = mindex.first
    if mindex.length == 1
      array[i] = value
    else
      set(array[i], mindex[1...], value)
    end
  end

  def prev(array, mindex)
    case mindex.last
    when 0
      prev_mindex = mindex.reverse.drop_while(&:zero?).reverse
      Mindex.prev array, prev_mindex
    when 1
      prev_mindex = mindex[...-1] + [0]
      prev_array = get array, prev_mindex
      prev_mindex + Mindex.last(prev_array)
    end
  end

  def next(array, mindex)
    case mindex.last
    when 0
      next_mindex = mindex[...-1] + [1]
      next_array = get array, next_mindex
      next_mindex + Mindex.first(next_array)
    when 1
      next_mindex = mindex.reverse.drop_while { |x| x == 1 }.reverse
      Mindex.next array, next_mindex
    end
  end

  def each(array, &block)
    mindex = Mindex.first(array)
    last = Mindex.last(array)

    loop do
      block.call mindex
      break if mindex == last

      mindex = Mindex.next array, mindex
    end
  end

  def find(array, &block)
    mindex = Mindex.first(array)
    last = Mindex.last(array)

    loop do
      return mindex if block.call mindex
      break if mindex == last

      mindex = Mindex.next array, mindex
    end
  end
end

def parse_data(io)
  io.map { |line| YAML.safe_load line.chomp }
end

def deepcopy(object)
  YAML.safe_load(YAML.dump(object), aliases: true)
end

def explode(number, mindex)
  explodee_mindex = mindex[...-1]
  explodee0, explodee1 = Mindex.get number, explodee_mindex

  prev_mindex = Mindex.prev number, explodee_mindex
  next_mindex = Mindex.next number, explodee_mindex
  exploded = deepcopy number

  unless prev_mindex.nil?
    prev_value = Mindex.get exploded, prev_mindex
    Mindex.set exploded, prev_mindex, prev_value + explodee0
  end

  unless next_mindex.nil?
    next_value = Mindex.get exploded, next_mindex
    Mindex.set exploded, next_mindex, next_value + explodee1
  end

  Mindex.set exploded, mindex[...-1], 0
  exploded
end

def split(number, mindex)
  value = Mindex.get number, mindex
  split_value = [value / 2, (value + 1) / 2]

  splitted = Marshal.load(Marshal.dump(number))
  Mindex.set splitted, mindex, split_value

  splitted
end

def settle(number)
  # explode
  explode_mindex = Mindex.find(number) { |mindex| mindex.length > 4 }
  return settle(explode(number, explode_mindex)) unless explode_mindex.nil?

  # split
  split_mindex = Mindex.find(number) { |mindex| Mindex.get(number, mindex) > 9 }
  return settle(split(number, split_mindex)) unless split_mindex.nil?

  number
end

def addition(number1, number2)
  settle [number1, number2]
end

def magnitude(number)
  case number
  when Integer then number
  when Array
    magnitude0 = magnitude number[0]
    magnitude1 = magnitude number[1]
    3 * magnitude0 + 2 * magnitude1
  end
end

def part1(io)
  numbers = parse_data io
  number = numbers.reduce { |number1, number2| addition number1, number2 }
  magnitude number
end

def part2(io)
  numbers = parse_data io
  numbers = numbers.product(numbers).map { |number1, number2| addition number1, number2 }
  magnitudes = numbers.map { |number| magnitude number }
  magnitudes.max
end

example = <<~EOF
  [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
  [[[5,[2,8]],4],[5,[[9,9],0]]]
  [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
  [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
  [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
  [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
  [[[[5,4],[7,7]],8],[[8,3],8]]
  [[9,3],[[9,9],[6,[4,9]]]]
  [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
  [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
EOF
test_example StringIO.open(example) { |io| part1 io }, 4140
test_example StringIO.open(example) { |io| part2 io }, 3993

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
