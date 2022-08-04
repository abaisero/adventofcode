#!/usr/bin/env ruby
# frozen_string_literal: true

def read_data(filename)
  File.foreach(filename).map { |line| line.strip.split(',') }
end

def apply_step(point, direction, stepsize)
  steps = { U: [0, 1], D: [0, -1], L: [-1, 0], R: [1, 0] }
  dx, dy = steps[direction]

  [point[0] + stepsize * dx, point[1] + stepsize * dy]
end

def get_wiresegment(point, wirestep)
  direction = wirestep[0].to_sym
  nsteps = wirestep[1...].to_i
  1.upto(nsteps).map { |stepsize| apply_step point, direction, stepsize }
end

def get_wiresegments(segments, wire)
  return segments if wire.empty?

  segment = get_wiresegment segments.last.last, wire.first
  get_wiresegments segments + [segment], wire.drop(1)
end

def get_wirepath(wire)
  segments = (get_wiresegments [[[0, 0]]], wire).drop(1)
  segments.flatten(1)
end

def find_intersections(wire1, wire2)
  path1 = get_wirepath wire1
  path2 = get_wirepath wire2
  path1 & path2
end

def manhattan_norm(point)
  point.map(&:abs).sum
end

def find_min_manhattan(wire1, wire2)
  find_intersections(wire1, wire2).map { |point| manhattan_norm point }.min
end

def part1(filename)
  wire1, wire2 = read_data filename
  find_min_manhattan wire1, wire2
end

def compute_delayhash(path)
  path.each.with_index(1).reverse_each.to_h
end

def find_min_delay(wire1, wire2)
  path1 = get_wirepath wire1
  path2 = get_wirepath wire2
  intersections = path1 & path2

  delayhash1 = compute_delayhash(path1)
  delayhash2 = compute_delayhash(path2)
  intersections.map { |point| delayhash1[point] + delayhash2[point] }.min
end

def part2(filename)
  wire1, wire2 = read_data filename
  find_min_delay wire1, wire2
end

output = [[1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0], [8, 0]]
raise unless get_wiresegment([0, 0], 'R8') == output

input1 = %w[R75 D30 R83 U83 L12 D49 R71 U7 L72]
input2 = %w[U62 R66 U55 R34 D71 R55 D58 R83]
raise unless find_min_manhattan(input1, input2) == 159

input1 = %w[R98 U47 R26 D63 R33 U87 L62 D20 R33 U53 R51]
input2 = %w[U98 R91 D20 R16 D67 R40 U7 R15 U6 R7]
raise unless find_min_manhattan(input1, input2) == 135

input1 = %w[R75 D30 R83 U83 L12 D49 R71 U7 L72]
input2 = %w[U62 R66 U55 R34 D71 R55 D58 R83]
raise unless find_min_delay(input1, input2) == 610

input1 = %w[R98 U47 R26 D63 R33 U87 L62 D20 R33 U53 R51]
input2 = %w[U98 R91 D20 R16 D67 R40 U7 R15 U6 R7]
raise unless find_min_delay(input1, input2) == 410

p part1 '03.txt'
p part2 '03.txt'
