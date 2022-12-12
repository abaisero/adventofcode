#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'
require 'stringio'
require_relative 'test'

def parse_data(io)
  io.map  do |line|
    line.match(/^([UDLR]) (\d+)$/) do |match|
      direction = match.captures[0].to_sym
      num_steps = match.captures[1].to_i

      [direction, num_steps]
    end
  end
end

def step(x, y)
  x + (y <=> x)
end

def init_rope(num_knots)
  num_knots.times.map { [0, 0] }
end

def move_rope_head(head, direction)
  head = head.dup
  case direction
  when :U then head[1] += 1
  when :D then head[1] -= 1
  when :L then head[0] -= 1
  when :R then head[0] += 1
  end
  head
end

def inf_norm(array1, array2)
  array1.zip(array2).map { |x, y| (x - y).abs }.max
end

def move_rope_knot(knot, knot_ahead)
  knot = knot.zip(knot_ahead).map { |x, y| step x, y } if inf_norm(knot, knot_ahead) > 1
  knot
end

def move_rope(rope, direction)
  new_rope = [move_rope_head(rope.first, direction)]
  rope[1...].each do |knot|
    new_rope << move_rope_knot(knot, new_rope.last)
  end
  new_rope
end

def count_tail_positions(movements, num_knots)
  rope = init_rope num_knots

  tail_positions = Set[rope.last]
  movements.each do |direction, num_steps|
    num_steps.times do
      rope = move_rope rope, direction
      tail_positions |= [rope.last]
    end
  end
  tail_positions.length
end

def part1(io)
  movements = parse_data io
  count_tail_positions movements, 2
end

def part2(io)
  movements = parse_data io
  count_tail_positions movements, 10
end

example = <<~EOF
  R 4
  U 4
  L 3
  D 1
  R 4
  D 1
  L 5
  R 2
EOF
test_example StringIO.open(example) { |io| part1 io }, 13
test_example StringIO.open(example) { |io| part2 io }, 1

example = <<~EOF
  U 8
  L 8
  D 3
  R 17
  D 10
  L 25
  U 20
EOF
test_example StringIO.open(example) { |io| part2 io }, 36

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
