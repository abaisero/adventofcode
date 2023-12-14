#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_io(io)
  lines = io.readlines chomp: true
  instructions = lines[0].chars.map(&:to_sym)
  transitions = lines[2...].map do |line|
    line.match(/^([A-Z0-9]{3}) = \(([A-Z0-9]{3}), ([A-Z0-9]{3})\)$/) do |match|
      from, left, right = match.captures
      [from, { L: left, R: right }]
    end
  end.to_h
  [instructions, transitions]
end

def count_steps(locations, instructions, transitions)
  0.step do |i|
    instruction_step = i % instructions.length
    instruction = instructions[instruction_step]
    locations = locations.map { |location| transitions[location][instruction] }
    print("#{i + 1}\n")
    return i + 1 if locations.all? { |location| location[-1] == 'Z' }
  end
end

def part1(io)
  instructions, transitions = parse_io io
  locations = ['AAA']
  count_steps locations, instructions, transitions
end

def find_steps(location, instructions, transitions)
  visited = []
  steps = []
  0.step do |i|
    steps << i + 1 if location[-1] == 'Z'
    return steps if visited.include? location

    visited << location
    instruction_step = i % instructions.length
    instruction = instructions[instruction_step]
    location = transitions[location][instruction]
  end
end

def find_next_final_location(location, i, instructions, transitions)
  instruction = instructions[i]
  location = transitions[location][instruction]
end

def find_summary(instructions, transitions, location, i)
  visited = []
  0.step do |step|
    visited << location
    instruction = instructions[(i + step) % instructions.length]
    location = transitions[location][instruction]
    return [location, step + 1] if location[-1] == 'Z'
    return nil if visited.include? location
  end
end

def summarize(instructions, transitions)
  locations = transitions.keys
  indices = (0...instructions.length).to_a

  summary = locations.product(indices).map do |location, i|
    key = [location, i]
    value = find_summary instructions, transitions, location, i
    [key, value] unless value.nil?
  end.compact.to_h
end

def part2(io)
  instructions, transitions = parse_io io
  summary = summarize instructions, transitions
  locations = transitions.keys.select { |location| location[-1] == 'A' }
  # steps = locations.map { |location| summary[[location, 0]][-1] }
  steps = locations.map { |_location| 0 }
  print "steps #{steps}\n"

  print(summary)
  print("\n")

  step = 0
  loop do
    step = steps.min
    break if steps.all? { |s| s.positive? && s == step }

    steps.each_with_index do |s, i|
      next if s != step

      location = locations[i]
      instruction_step = step % instructions.length
      next_location, delta = summary[[location, instruction_step]]
      print "from #{location} #{step}\n"
      print "to   #{next_location} #{delta}\n"

      locations[i] = next_location
      steps[i] += delta
    end
  end

  step
end

example = <<~EOF
  RL

  AAA = (BBB, CCC)
  BBB = (DDD, EEE)
  CCC = (ZZZ, GGG)
  DDD = (DDD, DDD)
  EEE = (EEE, EEE)
  GGG = (GGG, GGG)
  ZZZ = (ZZZ, ZZZ)
EOF
Test.example StringIO.open(example) { |io| part1 io }, 2

example = <<~EOF
  LR

  11A = (11B, XXX)
  11B = (XXX, 11Z)
  11Z = (11B, XXX)
  22A = (22B, XXX)
  22B = (22C, 22C)
  22C = (22Z, 22Z)
  22Z = (22B, 22B)
  XXX = (XXX, XXX)
EOF
Test.example StringIO.open(example) { |io| part2 io }, 6

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 21_797
Test.solution File.open(input) { |io| part2 io }, nil
