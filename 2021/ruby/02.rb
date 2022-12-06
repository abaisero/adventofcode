#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_data(io)
  io.map do |line|
    match = line.match(/^(?<command>\w+)\s+(?<x>\d+)$/)
    command, x = match.captures
    command = match[:command].to_sym
    x = match[:x].to_i
    { command: command, x: x }
  end
end

def update1(instruction, state)
  case instruction[:command]
  when :forward then state[:position] += instruction[:x]
  when :down then state[:depth] += instruction[:x]
  when :up then state[:depth] -= instruction[:x]
  end
end

def score(state)
  state[:position] * state[:depth]
end

def part1(io)
  instructions = parse_data io
  state = { position: 0, depth: 0 }
  instructions.each do |instruction|
    update1 instruction, state
  end
  score state
end

def update2(instruction, state)
  case instruction[:command]
  when :forward
    state[:position] += instruction[:x]
    state[:depth] += state[:aim] * instruction[:x]
  when :down then state[:aim] += instruction[:x]
  when :up then state[:aim] -= instruction[:x]
  end
end

def part2(io)
  instructions = parse_data io
  state = { position: 0, depth: 0, aim: 0 }
  instructions.each do |instruction|
    update2 instruction, state
  end
  score state
end

example = <<~EOF
  forward 5
  down 5
  forward 8
  up 3
  down 8
  forward 2
EOF
test_example StringIO.open(example) { |io| part1 io }, 150
test_example StringIO.open(example) { |io| part2 io }, 900

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
