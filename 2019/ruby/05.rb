#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'intcode'

def read_data(filename)
  File.read(filename).strip.split(',').map(&:to_i)
end

def run_program(program, input)
  program = program.dup
  run_instructions program, 0, input, []
end

raise unless get_parameter_modes(1002, 3) == %i[position immediate position]
raise unless run_program([3, 0, 4, 0, 99], 1) == [1]
raise unless run_program([3, 0, 4, 0, 99], 2) == [2]
raise unless run_program([3, 0, 4, 0, 99], 3) == [3]

def part1(filename)
  program = read_data filename
  outputs = run_program program, 1
  outputs.last
end

# Using position mode, consider whether the input is equal to 8; output 1 (if it is) or 0 (if it is not).
raise unless run_program([3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8], 7) == [0]
raise unless run_program([3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8], 8) == [1]
raise unless run_program([3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8], 9) == [0]

# Using position mode, consider whether the input is less than 8; output 1 (if it is) or 0 (if it is not).
raise unless run_program([3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8], 7) == [1]
raise unless run_program([3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8], 8) == [0]

# Using immediate mode, consider whether the input is equal to 8; output 1 (if it is) or 0 (if it is not).
raise unless run_program([3, 3, 1108, -1, 8, 3, 4, 3, 99], 7) == [0]
raise unless run_program([3, 3, 1108, -1, 8, 3, 4, 3, 99], 8) == [1]
raise unless run_program([3, 3, 1108, -1, 8, 3, 4, 3, 99], 9) == [0]
#
# Using immediate mode, consider whether the input is less than 8; output 1 (if it is) or 0 (if it is not).
raise unless run_program([3, 3, 1107, -1, 8, 3, 4, 3, 99], 7) == [1]
raise unless run_program([3, 3, 1107, -1, 8, 3, 4, 3, 99], 8) == [0]

# The above example program uses an input instruction to ask for a single
# number. The program will then output 999 if the input value is below 8,
# output 1000 if the input value is equal to 8, or output 1001 if the input
# value is greater than 8.

program = [3, 21, 1008, 21, 8, 20, 1005, 20, 22, 107, 8, 21, 20, 1006, 20, 31,
           1106, 0, 36, 98, 0, 0, 1002, 21, 125, 20, 4, 20, 1105, 1, 46, 104,
           999, 1105, 1, 46, 1101, 1000, 1, 20, 4, 20, 1105, 1, 46, 98, 99]
raise unless run_program(program, 7) == [999]
raise unless run_program(program, 8) == [1000]
raise unless run_program(program, 9) == [1001]

def part2(filename)
  program = read_data filename
  outputs = run_program program, 5
  outputs.last
end

p part1 '05.txt'
p part2 '05.txt'
