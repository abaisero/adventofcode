#!/usr/bin/env ruby
# frozen_string_literal: true

def read_data(filename)
  File.foreach(filename).map do |line|
    m = line.strip.match(/^(?<command>\w+)\s+(?<x>\d+)$/)
    command = m[:command].to_sym
    x = m[:x].to_i
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

def part1(filename)
  instructions = read_data filename
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

def part2(filename)
  instructions = read_data filename
  state = { position: 0, depth: 0, aim: 0 }
  instructions.each do |instruction|
    update2 instruction, state
  end
  score state
end

p part1 '02.example.txt'
p part1 '02.txt'
p part2 '02.example.txt'
p part2 '02.txt'
