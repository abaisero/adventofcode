#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'
require 'stringio'
require_relative 'test'

def parse_io_line(line)
  line.chars
end

def parse_io(io)
  lines = io.readlines chomp: true
  map = lines.map { |line| parse_io_line line }
  height = map.length
  width = map.first.length

  elves = Set[]
  for i in 0...height
    for j in 0...width
      elves << [i, j] if map[i][j] == '#'
    end
  end

  elves
end

def surrounding_elves?(elves, elf)
  i, j = elf
  deltas = [-1, 0, 1].product([-1, 0, 1]).reject { |di, dj| di.zero? && dj.zero? }
  deltas.any? { |di, dj| elves.include? [i + di, j + dj] }
end

def valid_direction?(elves, elf, direction)
  i, j = elf
  positions_to_check = case direction
                       when :N then [[i - 1, j - 1], [i - 1, j], [i - 1, j + 1]]
                       when :S then [[i + 1, j - 1], [i + 1, j], [i + 1, j + 1]]
                       when :E then [[i - 1, j + 1], [i, j + 1], [i + 1, j + 1]]
                       when :W then [[i - 1, j - 1], [i, j - 1], [i + 1, j - 1]]
                       end
  positions_to_check.all? { |position| !elves.include? position }
end

def move_elf(elf, direction)
  i, j = elf
  case direction
  when :N then [i - 1, j]
  when :S then [i + 1, j]
  when :E then [i, j + 1]
  when :W then [i, j - 1]
  end
end

def find_proposal(elves, elf, directions)
  # where will the elf try to move..?
  return elf.dup unless surrounding_elves? elves, elf

  direction = directions.find { |direction| valid_direction? elves, elf, direction }
  return move_elf(elf, direction) unless direction.nil?

  elf
end

def simulate_first_half(elves, directions)
  elves.map do |elf|
    proposal = find_proposal(elves, elf, directions)
    [elf, proposal]
  end.to_h
end

def simulate_second_half(proposals)
  proposal_counts = proposals.values.group_by(&:itself).transform_values(&:count)
  for key, value in proposals
    proposals[key] = key if proposal_counts[value] > 1
  end
  Set[*proposals.values]
end

def make_smallest_rectangle(elves)
  imin, imax = elves.map(&:first).minmax
  jmin, jmax = elves.map(&:last).minmax
  rectangle = Array.new(imax - imin + 1) { Array.new(jmax - jmin + 1) { '.' } }
  for i, j in elves
    rectangle[i - imin][j - jmin] = '#'
  end
  rectangle
end

def count_empty_positions(elves)
  rectangle = make_smallest_rectangle elves
  rectangle.flatten.count { |x| x == '.' }
end

def simulate(elves, directions)
  proposals = simulate_first_half elves, directions
  directions.rotate!
  simulate_second_half proposals
end

def part1(io)
  elves = parse_io io
  directions = %i[N S W E]
  10.times do
    elves = simulate elves, directions
  end
  count_empty_positions elves
end

def part2(io)
  elves = parse_io io
  directions = %i[N S W E]
  (1...).each do |i|
    new_elves = simulate elves, directions
    return i if new_elves == elves

    elves = new_elves
  end
end

example = <<~EOF
  ....#..
  ..###.#
  #...#.#
  .#...##
  #.###..
  ##.#.##
  .#..#..
EOF
Test.example StringIO.open(example) { |io| part1 io }, 110
Test.example StringIO.open(example) { |io| part2 io }, 20

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 3780
Test.solution File.open(input) { |io| part2 io }, 930
