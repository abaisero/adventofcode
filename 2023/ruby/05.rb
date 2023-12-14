#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_io(io)
  lines = io.readlines chomp: true
  seeds = lines[0].scan(/\d+/).map(&:to_i)
  lines = lines[1...]

  maps = []
  lines.map do |line|
    case line
    when /^[a-z]+-to-[a-z]+ map:$/
      maps << []
    when /^\d+ \d+ \d+$/
      maps.last << line.scan(/\d+/).map(&:to_i)
    end
  end

  [seeds, maps]
end

def convert_value(value, map)
  index = map.find_index do |_, source_range_start, range_length|
    source_range_start <= value && value < source_range_start + range_length
  end

  return value if index.nil?

  destination_range_start, source_range_start, = map[index]
  value - source_range_start + destination_range_start
end

def part1(io)
  seeds, maps = parse_io io

  values = seeds
  maps.each do |map|
    values = values.map { |value| convert_value value, map }
  end
  values.min
end

def convert_map(map)
  map.map do |destination_range_start, source_range_start, range_length|
    transformation = destination_range_start - source_range_start
    source_range_end = source_range_start + range_length - 1
    [source_range_start, source_range_end, transformation]
  end.sort
end

def complete_map(map)
  source = 0
  completed = []

  map.each do |source_range_start, source_range_end, transformation|
    completed << [source, source_range_start - 1, 0] if source < source_range_start
    completed << [source_range_start, source_range_end, transformation]
    source = source_range_end + 1
  end

  completed << [source, Float::INFINITY, 0]
  completed
end

def transform_range(range, map)
  range_start, range_end = range

  range_start_index = map.find_index do |source_range_start, source_range_end, _|
    source_range_start <= range_start && range_start <= source_range_end
  end
  range_end_index = map.find_index do |source_range_start, source_range_end, _|
    source_range_start <= range_end && range_end <= source_range_end
  end

  transformed = []
  (range_start_index..range_end_index).each do |i|
    _, source_range_end, transform = map[i]

    transformed_end = [range_end, source_range_end].min
    transformed << [range_start + transform, transformed_end + transform]
    range_start = source_range_end + 1
  end

  transformed
end

def seeds_as_ranges(seeds)
  ranges = seeds.each_slice(2).map { |start, length| [start, start + length - 1] }
  ranges.sort
end

def transform_ranges(ranges, map)
  ranges.map { |range| transform_range range, map }.flatten(1)
end

def part2(io)
  seeds, maps = parse_io io

  ranges = seeds_as_ranges seeds
  maps = maps.map { |map| complete_map(convert_map(map)) }
  maps.each { |map| ranges = transform_ranges ranges, map }
  ranges.map(&:first).min
end

example = <<~EOF
  seeds: 79 14 55 13

  seed-to-soil map:
  50 98 2
  52 50 48

  soil-to-fertilizer map:
  0 15 37
  37 52 2
  39 0 15

  fertilizer-to-water map:
  49 53 8
  0 11 42
  42 0 7
  57 7 4

  water-to-light map:
  88 18 7
  18 25 70

  light-to-temperature map:
  45 77 23
  81 45 19
  68 64 13

  temperature-to-humidity map:
  0 69 1
  1 0 69

  humidity-to-location map:
  60 56 37
  56 93 4
EOF
Test.example StringIO.open(example) { |io| part1 io }, 35
Test.example StringIO.open(example) { |io| part2 io }, 46

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 346_433_842
Test.solution File.open(input) { |io| part2 io }, 60_294_664
