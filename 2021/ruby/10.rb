#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_data(io)
  io.map { |line| line.chomp.chars }
end

def process_line(line)
  pairs = { '(' => ')', '[' => ']', '{' => '}', '<' => '>' }

  stack = []
  v = line.find do |value|
    if pairs.keys.include? value
      stack.append(value)
      false
    elsif pairs[stack.last] == value
      stack.pop
      false
    else
      true
    end
  end

  { stack: stack, value: v }
end

def part1(io)
  data = parse_data io
  scorehash = { ')' => 3, ']' => 57, '}' => 1197, '>' => 25_137 }
  keys = data.map { |line| process_line(line)[:value] }.compact
  keys.map { |k| scorehash[k] }.sum
end

def compute_score(stack)
  scores = { '(' => 1, '[' => 2, '{' => 3, '<' => 4 }
  score = 0
  stack.reverse.each { |c| score = 5 * score + scores[c] }
  score
end

def part2(io)
  data = parse_data io
  stacks = data.map { |line| process_line(line) }.select { |r| r[:value].nil? }.map { |r| r[:stack] }
  scores = stacks.map { |stack| compute_score stack }.sort
  scores[scores.length / 2]
end

example = <<~EOF
  [({(<(())[]>[[{[]{<()<>>
  [(()[<>])]({[<{<<[]>>(
  {([(<{}[<>[]}>{[]{[(<()>
  (((({<>}<{<{<>}{[]{[]{}
  [[<[([]))<([[{}[[()]]]
  [{[{({}]{}}([{[{{{}}([]
  {<[[]]>}<{[{[{[]{()[[[]
  [<(<(<(<{}))><([]([]()
  <{([([[(<>()){}]>(<<{{
  <{([{{}}[<[[[<>{}]]]>[]]
EOF
test_example StringIO.open(example) { |io| part1 io }, 26_397
test_example StringIO.open(example) { |io| part2 io }, 288_957

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
