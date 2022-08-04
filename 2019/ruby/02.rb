#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'intcode'

def read_data(filename)
  File.read(filename).strip.split(',').map(&:to_i)
end

def run_program(program, noun: nil, verb: nil)
  program = program.dup
  program[1] = noun unless noun.nil?
  program[2] = verb unless verb.nil?
  run_instructions program, 0, nil, []
  program
end

def part1(filename)
  program = read_data filename
  run_program(program, noun: 12, verb: 2).first
end

def part2(filename)
  program = read_data filename
  target = 19_690_720

  nouns = (0...100).to_a
  verbs = (0...100).to_a
  noun, verb = nouns.product(verbs).find do |noun, verb|
    run_program(program, noun: noun, verb: verb).first == target
  end
  100 * noun + verb
end

input = [1, 9, 10, 3, 2, 3, 11, 0, 99, 30, 40, 50]
output = [3500, 9, 10, 70, 2, 3, 11, 0, 99, 30, 40, 50]
raise 'ERROR' unless run_program(input) == output

input = [1, 0, 0, 0, 99]
output = [2, 0, 0, 0, 99]
raise 'ERROR' unless run_program(input) == output

input = [2, 3, 0, 3, 99]
output = [2, 3, 0, 6, 99]
raise 'ERROR' unless run_program(input) == output

input = [2, 4, 4, 5, 99, 0]
output = [2, 4, 4, 5, 99, 9801]
raise 'ERROR' unless run_program(input) == output

input = [1, 1, 1, 4, 99, 5, 6, 0, 99]
output = [30, 1, 1, 4, 2, 5, 6, 0, 99]
raise 'ERROR' unless run_program(input) == output

p part1 '02.txt'
p part2 '02.txt'
