#!/usr/bin/env ruby
# frozen_string_literal: true

def read_data(filename)
  parse_data File.foreach(filename)
end

def parse_data(lines)
  lines.map { |line| line.strip.split(')') }.group_by(&:first).transform_values { |values| values.map(&:last) }
end

def get_root(children)
  (children.keys - children.values.flatten).first
end

def count_depths_inner(children, element, depths, depth)
  depths[element] = depth

  return children unless children.key? element

  children[element].each do |e|
    count_depths_inner children, e, depths, depth + 1
  end
end

def count_depths(children)
  root = get_root children
  depths = {}
  count_depths_inner children, root, depths, 0
  depths
end

def count_orbits(orbits)
  (count_depths orbits).values.sum
end

def tests
  orbits = parse_data "COM)B\nB)C\nC)D\nD)E\nE)F\nB)G\nG)H\nD)I\nE)J\nJ)K\nK)L".each_line
  depths = count_depths orbits
  raise unless depths == { 'COM' => 0, 'B' => 1, 'C' => 2, 'D' => 3, 'E' => 4, 'F' => 5, 'G' => 2, 'H' => 3, 'I' => 4,
                           'J' => 5, 'K' => 6, 'L' => 7 }
  raise unless count_orbits(orbits) == 42
end

def part1(filename)
  orbits = read_data filename
  count_orbits orbits
end

def part2(filename)
  orbits = read_data filename
  # counts = count_orbits orbits
end

tests
p part1 '06.txt'
# p part2 '06.txt'
