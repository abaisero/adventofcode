#!/usr/bin/env ruby
# frozen_string_literal: true

def read_data(filename)
  File.foreach(filename).map { |line| line.strip.split('') }
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

def part1(filename)
  data = read_data filename
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

def part2(filename)
  data = read_data filename
  stacks = data.map { |line| process_line(line) }.select { |r| r[:value].nil? }.map { |r| r[:stack] }
  scores = stacks.map { |stack| compute_score stack }.sort
  scores[scores.length / 2]
end

p part1 '10.example.txt'
p part1 '10.txt'
p part2 '10.example.txt'
p part2 '10.txt'
