#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_io_line(line)
  line.to_i
end

def parse_io(io)
  lines = io.readlines chomp: true
  lines.map { |line| parse_io_line line }
end

def mixing(numbers, ids)
  n = numbers.length

  for id in 0...n
    index = ids.index id
    number = numbers[index]
    div, mod = number.divmod n

    unless div.zero?
      ids.delete_at index
      ids.rotate! div
      ids.insert index, id

      numbers.delete_at index
      numbers.rotate! div
      numbers.insert index, number
    end

    next if mod.zero?

    ids.rotate! index
    ids = ids[..mod].rotate + ids[mod + 1...]
    ids.rotate!(-index)

    numbers.rotate! index
    numbers = numbers[..mod].rotate + numbers[mod + 1...]
    numbers.rotate!(-index)
  end

  [numbers, ids]
end

def apply_mixing(numbers, n)
  ids = (0...numbers.length).to_a
  n.times do
    numbers, ids = mixing numbers, ids
  end
  numbers
end

def extract_coordinates(numbers)
  i0 = numbers.index 0
  [1000, 2000, 3000].map do |di|
    index = (i0 + di) % numbers.length
    numbers[index]
  end
end

def part1(io)
  numbers = parse_io io
  numbers = apply_mixing numbers, 1
  extract_coordinates(numbers).sum
end

def apply_decryption_key(numbers, decryption_key)
  numbers.map { |number| number * decryption_key }
end

def part2(io)
  numbers = parse_io io
  numbers = apply_decryption_key numbers, 811_589_153
  numbers = apply_mixing numbers, 10
  extract_coordinates(numbers).sum
end

example = <<~EOF
  1
  2
  -3
  3
  -2
  0
  4
EOF
Test.example StringIO.open(example) { |io| part1 io }, 3
Test.example StringIO.open(example) { |io| part2 io }, 1_623_178_306

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 9687
Test.solution File.open(input) { |io| part2 io }, 1_338_310_513_297
