#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'data_stack'
require_relative 'test'

module Crate
  def self.new(char)
    { char: char }
  end

  def self.char(crate)
    crate[:char]
  end
end

module Stack
  def self.new(crates = nil)
    FrozenArray.new crates
  end

  def self.top_crates(stack, n)
    stack.last n
  end

  def self.top_crate(stack)
    stack.last
  end

  def self.add_top_crates(stack, crates)
    Stack.new stack + crates
  end

  def self.add_top_crate(stack, crate)
    Stack.new stack + [crate]
  end

  def self.remove_top_crates(stack, n)
    Stack.new stack[...-n]
  end

  def self.pop_top_crates(stack, n)
    crates = Stack.top_crates stack, n
    stack = Stack.new stack[...-n]
    [stack, crates]
  end
end

module Stacks
  def self.new
    FrozenHash.new
  end

  def self.get_ids(stacks)
    stacks.keys
  end

  def self.get_stack(stacks, id)
    raise 'invalid id' unless stacks.key? id

    stacks[id]
  end

  def self.set_stack(stacks, id, stack)
    FrozenHash.set stacks, id, stack
  end
end

module Instruction
  FIELDS = %i[num_crates origin_id destination_id].freeze

  def self.new(num_crates, origin_id, destination_id)
    {
      num_crates: num_crates,
      origin_id: origin_id,
      destination_id: destination_id
    }
  end

  def self.get_field(instruction, field)
    raise 'invalid field' unless FIELDS.include? field

    instruction[field]
  end

  def self.set_field(instruction, field, value)
    raise 'invalid field' unless FIELDS.include? field

    instruction = instruction.dup
    instruction[field] = value
    instruction
  end
end

module StackOperations
  def self.create_stacks(stack_ids)
    stacks = Stacks.new
    stack_ids.each do |id|
      stack = Stack.new
      stacks = Stacks.set_stack stacks, id, stack
    end
    stacks
  end

  def self.apply_instruction(stacks, instruction)
    num_crates = Instruction.get_field instruction, :num_crates
    origin_id = Instruction.get_field instruction, :origin_id
    destination_id = Instruction.get_field instruction, :destination_id

    origin_stack = Stacks.get_stack stacks, origin_id
    destination_stack = Stacks.get_stack stacks, destination_id

    origin_stack, crates = Stack.pop_top_crates origin_stack, num_crates
    destination_stack = Stack.add_top_crates destination_stack, crates

    stacks = Stacks.set_stack stacks, origin_id, origin_stack
    Stacks.set_stack stacks, destination_id, destination_stack
  end

  def self.get_top_crates(stacks)
    stack_ids = Stacks.get_ids stacks
    stack_ids.sort.map do |id|
      stack = Stacks.get_stack stacks, id
      Stack.top_crate stack
    end
  end

  def self.format_top_crates(stacks)
    crates = get_top_crates stacks
    chars = crates.map { |crate| Crate.char crate }
    chars.join
  end
end

def parse_id_line(id_line)
  id_line.scan(/\d+/).map(&:to_i)
end

def get_char_from_line(line, id_line, id)
  index = id_line.index id.to_s
  line[index]
end

def get_crate_from_line(line, id_line, id)
  char = get_char_from_line line, id_line, id
  Crate.new char unless char == ' '
end

def parse_stacks(stack_lines, id_line)
  stack_ids = parse_id_line id_line
  stacks = StackOperations.create_stacks stack_ids
  stack_lines.reverse_each do |line|
    stack_ids.each do |id|
      crate = get_crate_from_line line, id_line, id
      next if crate.nil?

      stack = Stacks.get_stack stacks, id
      stack = Stack.add_top_crate stack, crate
      stacks = Stacks.set_stack stacks, id, stack
    end
  end

  stacks
end

def parse_instruction_line(line)
  line.match(/move (\d+) from (\d+) to (\d+)/) do |match|
    num_crates, origin_id, destination_id = match.captures.map(&:to_i)
    Instruction.new num_crates, origin_id, destination_id
  end
end

def parse_instructions(lines)
  lines.map { |line| parse_instruction_line line }
end

def parse_io(io)
  lines = io.readlines chomp: true

  stack_lines = lines.take_while { |line| !line.empty? }
  *stack_lines, id_line = stack_lines
  stacks = parse_stacks stack_lines, id_line

  instruction_lines = lines.reverse.take_while { |line| !line.empty? }.reverse
  instructions = parse_instructions instruction_lines

  [stacks, instructions]
end

def apply_instructions_part1(stacks, instructions)
  instructions.each do |instruction|
    num_crates = Instruction.get_field instruction, :num_crates
    unit_instruction = Instruction.set_field instruction, :num_crates, 1
    num_crates.times do
      stacks = StackOperations.apply_instruction stacks, unit_instruction
    end
  end
  stacks
end

def part1(io)
  stacks, instructions = parse_io io
  stacks = apply_instructions_part1 stacks, instructions
  StackOperations.format_top_crates stacks
end

def apply_instructions_part2(stacks, instructions)
  instructions.each do |instruction|
    stacks = StackOperations.apply_instruction stacks, instruction
  end
  stacks
end

def part2(io)
  stacks, instructions = parse_io io
  stacks = apply_instructions_part2 stacks, instructions
  StackOperations.format_top_crates stacks
end

example = <<~EOF
      [D]
  [N] [C]
  [Z] [M] [P]
   1   2   3

  move 1 from 2 to 1
  move 3 from 1 to 3
  move 2 from 2 to 1
  move 1 from 1 to 2
EOF
Test.example StringIO.open(example) { |io| part1 io }, 'CMZ'
Test.example StringIO.open(example) { |io| part2 io }, 'MCD'

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 'WSFTMRHPP'
Test.solution File.open(input) { |io| part2 io }, 'GSLCMFBRP'
