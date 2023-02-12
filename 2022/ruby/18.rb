#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_io_line(line)
  line.scan(/\d+/).map(&:to_i)
end

def parse_io(io)
  lines = io.readlines chomp: true
  lines.map { |line| parse_io_line line }
end

def count_nonadjacent_pairs(values)
  return 0 if values.empty?

  values.sort.each_cons(2).count { |a, b| b - a != 1 }
end

def surface_area(voxels)
  surfaces = []
  surfaces += voxels.group_by { |_, y, z| [y, z] }.values.map { |points| points.map { |x, _, _| x } }
  surfaces += voxels.group_by { |x, _, z| [x, z] }.values.map { |points| points.map { |_, y, _| y } }
  surfaces += voxels.group_by { |x, y, _| [x, y] }.values.map { |points| points.map { |_, _, z| z } }
  surfaces.map { |values| 2 + 2 * count_nonadjacent_pairs(values) }.sum
end

def part1(io)
  voxels = parse_io io
  surface_area voxels
end

def compute_shape(voxels)
  xmin, xmax = voxels.map { |x, _, _| x }.minmax
  ymin, ymax = voxels.map { |_, y, _| y }.minmax
  zmin, zmax = voxels.map { |_, _, z| z }.minmax

  [
    [xmin - 1, ymin - 1, zmin - 1],
    [xmax + 1, ymax + 1, zmax + 1]
  ]
end

def shape_surface_area(shape)
  xmin, ymin, zmin = shape[0]
  xmax, ymax, zmax = shape[1]

  lx = xmax - xmin + 1
  ly = ymax - ymin + 1
  lz = zmax - zmin + 1
  (lx + ly + lz)**2 - lx**2 - ly**2 - lz**2
end

def neighbors(voxel, shape)
  x, y, z = voxel

  candidates = [
    [x - 1, y, z],
    [x + 1, y, z],
    [x, y - 1, z],
    [x, y + 1, z],
    [x, y, z - 1],
    [x, y, z + 1]
  ]
  candidates.select do |x, y, z|
    x.between?(shape[0][0], shape[1][0]) && \
      y.between?(shape[0][1], shape[1][1]) && \
      z.between?(shape[0][2], shape[1][2])
  end
end

def compute_conjugate_voxels(voxels, shape)
  boundary = [shape.first]
  conjugate_voxels = [shape.first]
  until boundary.empty?
    voxel = boundary.pop
    neighbors(voxel, shape).each do |neighbor|
      next if conjugate_voxels.include? neighbor
      next if boundary.include? neighbor
      next if voxels.include? neighbor

      boundary << neighbor
      conjugate_voxels << neighbor
    end
  end

  conjugate_voxels
end

def part2(io)
  voxels = parse_io io
  shape = compute_shape voxels
  conjugate_voxels = compute_conjugate_voxels voxels, shape
  surface_area(conjugate_voxels) - shape_surface_area(shape)
end

example = <<~EOF
  1,1,1
  2,1,1
EOF
Test.example StringIO.open(example) { |io| part1 io }, 10

example = <<~EOF
  2,2,2
  1,2,2
  3,2,2
  2,1,2
  2,3,2
  2,2,1
  2,2,3
  2,2,4
  2,2,6
  1,2,5
  3,2,5
  2,1,5
  2,3,5
EOF
Test.example StringIO.open(example) { |io| part1 io }, 64
Test.example StringIO.open(example) { |io| part2 io }, 58

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 4348
Test.solution File.open(input) { |io| part2 io }, 2546
