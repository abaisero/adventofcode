#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'
require 'stringio'
require_relative 'linalgtools'
require_relative 'test'

def parse_io_line(line)
  line.match(/^([UDLR]) (\d+)$/) do |match|
    direction = match.captures[0].to_sym
    num_steps = match.captures[1].to_i

    [direction, num_steps]
  end
end

def parse_io(io)
  lines = io.readlines chomp: true
  lines.map { |line| parse_io_line line }
end

def step(x, y)
  x + (y <=> x)
end

def init_rope(num_knots)
  num_knots.times.map { [0, 0] }
end

def move_rope_head(head, direction)
  x, y = head
  case direction
  when :U then [x, y + 1]
  when :D then [x, y - 1]
  when :L then [x - 1, y]
  when :R then [x + 1, y]
  end
end

def move_rope_knot(knot, knot_ahead)
  move_knot = LinAlg.inf_dist(knot, knot_ahead) > 1
  knot = knot.zip(knot_ahead).map { |x, y| step x, y } if move_knot
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
      tail_positions << rope.last
    end
  end
  tail_positions.length
end

def part1(io)
  movements = parse_io io
  count_tail_positions movements, 2
end

def part2(io)
  movements = parse_io io
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
Test.example StringIO.open(example) { |io| part1 io }, 13
Test.example StringIO.open(example) { |io| part2 io }, 1

example = <<~EOF
  U 8
  L 8
  D 3
  R 17
  D 10
  L 25
  U 20
EOF
Test.example StringIO.open(example) { |io| part2 io }, 36

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 6256
Test.solution File.open(input) { |io| part2 io }, 2665
