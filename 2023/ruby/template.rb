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
  parse_io io
end

def part2(io)
  parse_io io
end

example = <<~EOF
EOF
Test.example StringIO.open(example) { |io| part1 io }, nil
# Test.example StringIO.open(example) { |io| part2 io }, nil

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, nil
# Test.solution File.open(input) { |io| part2 io }, nil
