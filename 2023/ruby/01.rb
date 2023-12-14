#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_io_line(line)
  line
end

def parse_io(io)
  lines = io.readlines chomp: true
  lines.map { |line| parse_io_line line }
end

def part1(io)
  documents = parse_io io
  documents_digits = documents.map do |document|
    document.gsub(/[a-z]+/, '').chars.map(&:to_i)
  end
  values = documents_digits.map { |digits| 10 * digits[0] + digits[-1] }
  values.sum
end

def part2(io)
  documents = parse_io io
  documents_digits = documents.map do |document|
    (0...document.length).filter_map do |i|
      case document[i...]
      when /^[0-9]/ then document[i].to_i
      when /^one/ then 1
      when /^two/ then 2
      when /^three/ then 3
      when /^four/ then 4
      when /^five/ then 5
      when /^six/ then 6
      when /^seven/ then 7
      when /^eight/ then 8
      when /^nine/ then 9
      end
    end
  end
  values = documents_digits.map { |digits| 10 * digits[0] + digits[-1] }
  values.sum
end

example = <<~EOF
  1abc2
  pqr3stu8vwx
  a1b2c3d4e5f
  treb7uchet
EOF
Test.example StringIO.open(example) { |io| part1 io }, 142

example = <<~EOF
  two1nine
  eightwothree
  abcone2threexyz
  xtwone3four
  4nineeightseven2
  zoneight234
  7pqrstsixteen
EOF
Test.example StringIO.open(example) { |io| part2 io }, 281

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 54_708
Test.solution File.open(input) { |io| part2 io }, 54_087
