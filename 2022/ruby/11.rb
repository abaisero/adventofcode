#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_io_line(line, monkeys)
  case line
  when /^\s*Monkey \d+:$/
    monkeys << { inspections: 0 }
  when /^\s*Starting items: (\d+(?:, \d+)*)$/
    monkeys.last[:items] = Regexp.last_match(1).scan(/\d+/).map(&:to_i)
  when /^\s*Operation: new = old \* old$/
    monkeys.last[:operation] = ->(old) { old * old }
  when /^\s*Operation: new = old \* (\d+)$/
    capture = Regexp.last_match(1).to_i
    monkeys.last[:operation] = ->(old) { old * capture }
  when /^\s*Operation: new = old \+ (\d+)$/
    capture = Regexp.last_match(1).to_i
    monkeys.last[:operation] = ->(old) { old + capture }
  when /^\s*Test: divisible by (\d+)$/
    monkeys.last[:test_value] = Regexp.last_match(1).to_i
  when /^\s*If true: throw to monkey (\d+)$/
    monkeys.last[[:test_result, true]] = Regexp.last_match(1).to_i
  when /^\s*If false: throw to monkey (\d+)$/
    monkeys.last[[:test_result, false]] = Regexp.last_match(1).to_i
  end
end

def parse_io(io)
  lines = io.readlines chomp: true

  monkeys = []
  lines.each do |line|
    parse_io_line line, monkeys
  end
  monkeys
end

def process_item(monkeys, monkey, item, postoperation)
  monkey[:inspections] += 1

  item = monkey[:operation].call item
  item = postoperation.call item

  test = (item % monkey[:test_value]).zero?
  next_monkey_id = monkey[[:test_result, test]]
  next_monkey = monkeys[next_monkey_id]
  next_monkey[:items] << item
end

def process_turn(monkeys, monkey, postoperation)
  monkey[:items].each do |item|
    process_item monkeys, monkey, item, postoperation
  end
  monkey[:items] = []
end

def process_round(monkeys, postoperation)
  monkeys.each do |monkey|
    process_turn monkeys, monkey, postoperation
  end
end

def monkey_business(monkeys)
  inspections = monkeys.map { |monkey| monkey[:inspections] }
  inspections.max(2).reduce(:*)
end

def part1(io)
  monkeys = parse_io io
  postoperation = ->(item) { item / 3 }
  20.times do
    process_round monkeys, postoperation
  end
  monkey_business monkeys
end

def part2(io)
  monkeys = parse_io io
  test_value_lcm = monkeys.map { |monkey| monkey[:test_value] }.reduce(:lcm)
  postoperation = ->(item) { item % test_value_lcm }
  10_000.times do
    process_round monkeys, postoperation
  end
  monkey_business monkeys
end

example = <<~EOF
  Monkey 0:
    Starting items: 79, 98
    Operation: new = old * 19
    Test: divisible by 23
      If true: throw to monkey 2
      If false: throw to monkey 3

  Monkey 1:
    Starting items: 54, 65, 75, 74
    Operation: new = old + 6
    Test: divisible by 19
      If true: throw to monkey 2
      If false: throw to monkey 0

  Monkey 2:
    Starting items: 79, 60, 97
    Operation: new = old * old
    Test: divisible by 13
      If true: throw to monkey 1
      If false: throw to monkey 3

  Monkey 3:
    Starting items: 74
    Operation: new = old + 3
    Test: divisible by 17
      If true: throw to monkey 0
      If false: throw to monkey 1
EOF
Test.example StringIO.open(example) { |io| part1 io }, 10_605
Test.example StringIO.open(example) { |io| part2 io }, 2_713_310_158

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 58_786
Test.solution File.open(input) { |io| part2 io }, 14_952_185_856
