#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'data_stack'
require_relative 'test'

module SectionRange
  def self.new(min, max)
    { min: min, max: max }
  end

  def self.min(range)
    range[:min]
  end

  def self.max(range)
    range[:max]
  end
end

def parse_io_line(line)
  line.match(/^(\d+)-(\d+),(\d+)-(\d+)$/) do |match|
    xmin, xmax, ymin, ymax = match.captures.map(&:to_i)
    xrange = SectionRange.new xmin, xmax
    yrange = SectionRange.new ymin, ymax
    FrozenArray.new [xrange, yrange]
  end
end

def parse_io(io)
  lines = io.readlines chomp: true
  ranges = lines.map { |line| parse_io_line line }
  FrozenArray.new ranges
end

module SectionRangeOperations
  def self.max_min(xrange, yrange)
    xmin = SectionRange.min xrange
    ymin = SectionRange.min yrange
    [xmin, ymin].max
  end

  def self.min_max(xrange, yrange)
    xmax = SectionRange.max xrange
    ymax = SectionRange.max yrange
    [xmax, ymax].min
  end

  def self.overlap(xrange, yrange)
    zmin = SectionRangeOperations.max_min xrange, yrange
    zmax = SectionRangeOperations.min_max xrange, yrange
    SectionRange.new zmin, zmax if zmin <= zmax
  end

  def self.full_overlap?(xrange, yrange)
    overlap = SectionRangeOperations.overlap xrange, yrange
    overlap == xrange || overlap == yrange
  end

  def self.partial_overlap?(xrange, yrange)
    overlap = SectionRangeOperations.overlap xrange, yrange
    !overlap.nil?
  end
end

module BusinessLogic
  def self.count_full_overlaps(ranges)
    ranges.count { |xrange, yrange| SectionRangeOperations.full_overlap? xrange, yrange }
  end

  def self.count_partial_overlaps(ranges)
    ranges.count { |xrange, yrange| SectionRangeOperations.partial_overlap? xrange, yrange }
  end
end

def part1(io)
  ranges = parse_io io
  BusinessLogic.count_full_overlaps ranges
end

def part2(io)
  ranges = parse_io io
  BusinessLogic.count_partial_overlaps ranges
end

example = <<~EOF
  2-4,6-8
  2-3,4-5
  5-7,7-9
  2-8,3-7
  6-6,4-6
  2-6,4-8
EOF
Test.example StringIO.open(example) { |io| part1 io }, 2
Test.example StringIO.open(example) { |io| part2 io }, 4

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 556
Test.solution File.open(input) { |io| part2 io }, 876
