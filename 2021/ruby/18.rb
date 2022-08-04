#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'

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

def read_data(filename)
  File.foreach(filename).map { |line| YAML.safe_load line.strip }
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

def part1(filename)
  numbers = read_data filename
  number = numbers.reduce { |number1, number2| addition number1, number2 }
  magnitude number
end

def part2(filename)
  numbers = read_data filename
  numbers = numbers.product(numbers).map { |number1, number2| addition number1, number2 }
  magnitudes = numbers.map { |number| magnitude number }
  magnitudes.max
end

p part1 '18.example.txt'
p part1 '18.txt'
p part2 '18.example.txt'
p part2 '18.txt'
