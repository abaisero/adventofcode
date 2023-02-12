#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'linalgtools'
require_relative 'test'

def parse_io_line(line)
  xsensor, ysensor, xbeacon, ybeacon = line.scan(/-?\d+/).map(&:to_i)
  [[xsensor, ysensor], [xbeacon, ybeacon]]
end

def parse_io(io)
  lines = io.readlines chomp: true
  lines.map { |line| parse_io_line line }
end

def overlap?(segment1, segment2)
  segment1.first <= segment2.first && segment2.first <= segment1.last \
    || segment2.first <= segment1.first && segment1.first <= segment2.last
end

def compute_segments(readings, y)
  segments = readings.filter_map do |sensor, beacon|
    xsensor, ysensor = sensor

    dist = LinAlg.l1_dist sensor, beacon
    ydist = (ysensor - y).abs
    xdist = dist - ydist

    next unless xdist.positive?

    x0 = xsensor - xdist
    x1 = xsensor + xdist
    [x0, x1]
  end
  compact_segments segments
end

def combine_overlapping_segments(segment1, segment2)
  x0, x1 = segment1
  y0, y1 = segment2
  z0 = [x0, y0].min
  z1 = [x1, y1].max
  [z0, z1]
end

def compact_segments(segments)
  compact_segments = []
  segments.sort.each do |segment|
    compact_segments << segment if compact_segments.empty?

    next unless overlap? segment, compact_segments.last

    compact_segments[-1] = combine_overlapping_segments compact_segments[-1], segment
  end
  compact_segments
end

def compute_beacons(readings, y)
  readings.filter_map do |_, beacon|
    xbeacon, ybeacon = beacon
    xbeacon if ybeacon == y
  end.uniq
end

def segments_area(segments)
  segments.map { |x0, x1| x1 - x0 + 1 }.sum
end

def overlapping_beacons(segments, beacons)
  beacons.select { |x| segments.any? { |x0, x1| x.between? x0, x1 } }
end

def total_area(segments, beacons)
  segments_area(segments) - overlapping_beacons(segments, beacons).count
end

def part1(io, y)
  readings = parse_io io
  segments = compute_segments readings, y
  beacons = compute_beacons readings, y
  total_area segments, beacons
end

def manhattan_border(sensor, dist)
  xsensor, ysensor = sensor

  (0..dist).lazy.flat_map do |xdist|
    ydist = dist - xdist

    xs = [xsensor - xdist, xsensor + xdist]
    ys = [ysensor - ydist, ysensor + ydist]
    xs.product ys
  end
end

def beacon_candidates(readings, max)
  readings.lazy.flat_map do |sensor, beacon|
    dist = LinAlg.l1_dist sensor, beacon
    candidates = manhattan_border sensor, dist + 1
    candidates.select { |x, y| x.between?(0, max) && y.between?(0, max) }
  end.uniq
end

def find_beacon(readings, max)
  sensors = readings.map(&:first)
  dists = readings.map { |sensor, beacon| LinAlg.l1_dist sensor, beacon }
  # puts "dists #{dists}"
  # puts "total #{dists.sum}"

  beacon_candidates(readings, max).find do |candidate|
    sensors.zip(dists).all? { |sensor, dist| LinAlg.l1_dist(sensor, candidate) > dist }
  end
end

def tuning_frequency(beacon)
  xbeacon, ybeacon = beacon
  4_000_000 * xbeacon + ybeacon
end

def part2(io, max)
  readings = parse_io io
  beacon = find_beacon readings, max
  tuning_frequency beacon
end

example = <<~EOF
  Sensor at x=2, y=18: closest beacon is at x=-2, y=15
  Sensor at x=9, y=16: closest beacon is at x=10, y=16
  Sensor at x=13, y=2: closest beacon is at x=15, y=3
  Sensor at x=12, y=14: closest beacon is at x=10, y=16
  Sensor at x=10, y=20: closest beacon is at x=10, y=16
  Sensor at x=14, y=17: closest beacon is at x=10, y=16
  Sensor at x=8, y=7: closest beacon is at x=2, y=10
  Sensor at x=2, y=0: closest beacon is at x=2, y=10
  Sensor at x=0, y=11: closest beacon is at x=2, y=10
  Sensor at x=20, y=14: closest beacon is at x=25, y=17
  Sensor at x=17, y=20: closest beacon is at x=21, y=22
  Sensor at x=16, y=7: closest beacon is at x=15, y=3
  Sensor at x=14, y=3: closest beacon is at x=15, y=3
  Sensor at x=20, y=1: closest beacon is at x=15, y=3
EOF
Test.example StringIO.open(example) { |io| part1 io, 10 }, 26
Test.example StringIO.open(example) { |io| part2 io, 20 }, 56_000_011

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io, 2_000_000 }, 4_827_924
Test.solution File.open(input) { |io| part2 io, 4_000_000 }, 12_977_110_973_564
