#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_io_line(line)
  case line
  when /([a-z]{4}): (\d+)/
    monkey = Regexp.last_match(1)
    number = Regexp.last_match(2).to_i
    riddle = { type: :number, number: number }
  when /([a-z]{4}): ([a-z]{4}) (.) ([a-z]{4})/
    monkey = Regexp.last_match(1)
    operation = Regexp.last_match(3).to_sym
    monkeys = [Regexp.last_match(2), Regexp.last_match(4)]
    riddle = { type: :operation, operation: operation, monkeys: monkeys }
  end
  [monkey, riddle]
end

def parse_io(io)
  lines = io.readlines chomp: true
  lines.map { |line| parse_io_line line }.to_h
end

def solve_riddle_part1(riddles, monkey)
  riddle = riddles[monkey]
  case riddle[:type]
  when :number
    number = riddle[:number]
  when :operation
    numbers = riddle[:monkeys].map { |m| solve_riddle_part1 riddles, m }
    number = numbers.reduce riddle[:operation]
  end
  number
end

def part1(io)
  riddles = parse_io io
  solve_riddle_part1 riddles, 'root'
end

def compute_ancestors(riddles, monkey)
  ancestors = [monkey]
  while monkey != 'root'
    monkey = riddles.keys.find { |k| k if riddles[k][:type] == :operation && riddles[k][:monkeys].include?(monkey) }
    ancestors << monkey
  end
  ancestors.reverse
end

def extract_human_ancestor(riddles, ancestors, monkey)
  raise unless riddles[monkey][:type] == :operation

  ancestor, = riddle[:monkeys] & ancestors
  other, = riddle[:monkeys] - ancestors
end

def find_human_value(riddles, ancestors, monkey, value)
  # which value of control makes it such that the monkey assumes the given value

  return value if monkey == 'humn'

  riddle = riddles[monkey]

  raise unless riddle[:type] == :operation
  raise unless riddle[:monkeys].length == 2

  ancestor_index = ancestors.include?(riddle[:monkeys][0]) ? 0 : 1
  ancestor = riddle[:monkeys][ancestor_index]
  other_index = 1 - ancestor_index
  other_value = solve_riddle_part1 riddles, riddle[:monkeys][other_index]

  ancestor_value = case riddle[:operation]
                   when :+ then value - other_value
                   when :- then ancestor_index == 0 ? value + other_value : other_value - value
                   when :* then value / other_value
                   when :/ then ancestor_index == 0 ? value * other_value : other_value / value
                   end

  find_human_value riddles, ancestors, ancestor, ancestor_value
end

def solve_riddle_part2(riddles)
  ancestors = compute_ancestors riddles, 'humn'

  riddle = riddles['root']
  ancestor_index = ancestors.include?(riddle[:monkeys][0]) ? 0 : 1
  ancestor = riddle[:monkeys][ancestor_index]
  other_index = 1 - ancestor_index
  other_value = solve_riddle_part1 riddles, riddle[:monkeys][other_index]

  find_human_value riddles, ancestors, ancestor, other_value
end

def part2(io)
  riddles = parse_io io
  solve_riddle_part2 riddles
end

example = <<~EOF
  root: pppw + sjmn
  dbpl: 5
  cczh: sllz + lgvd
  zczc: 2
  ptdq: humn - dvpt
  dvpt: 3
  lfqf: 4
  humn: 5
  ljgn: 2
  sjmn: drzm * dbpl
  sllz: 4
  pppw: cczh / lfqf
  lgvd: ljgn * ptdq
  drzm: hmdt - zczc
  hmdt: 32
EOF
Test.example StringIO.open(example) { |io| part1 io }, 152
Test.example StringIO.open(example) { |io| part2 io }, 301

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 155_708_040_358_220
Test.solution File.open(input) { |io| part2 io }, 3_342_154_812_537
