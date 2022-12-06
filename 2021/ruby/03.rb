#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_data(io)
  io.map { |line| line.chomp.each_char.map(&:to_i) }
end

def bits_to_int(bits)
  bits.map(&:to_s).join.to_i(2)
end

def compute_gamma_rating(report, bitcounts)
  gammabits = bitcounts.map { |bitcount| 2 * bitcount > report.length ? 1 : 0 }
  bits_to_int gammabits
end

def compute_epsilon_rating(report, bitcounts)
  epsilonbits = bitcounts.map { |bitcount| 2 * bitcount >= report.length ? 0 : 1 }
  bits_to_int epsilonbits
end

def part1(io)
  report = parse_data io

  bitcounts = report.transpose.map(&:sum)
  gamma_rating = compute_gamma_rating report, bitcounts
  epsilon_rating = compute_epsilon_rating report, bitcounts
  gamma_rating * epsilon_rating
end

def compute_rating(bitarrays, select_key, index = 0)
  return bits_to_int bitarrays[0] if bitarrays.one?

  groups = bitarrays.group_by { |bitarray| bitarray[index] }
  bitarrays = if groups.keys.one?
                groups[groups.keys[0]]
              elsif groups[0].length <= groups[1].length
                groups[select_key]
              else
                groups[1 - select_key]
              end

  compute_rating bitarrays, select_key, index + 1
end

def compute_oxygen_rating(report)
  compute_rating report, 1
end

def compute_co2_rating(report)
  compute_rating report, 0
end

def part2(io)
  report = parse_data io

  oxygen_rating = compute_oxygen_rating report
  co2_rating = compute_co2_rating report
  oxygen_rating * co2_rating
end

example = <<~EOF
  00100
  11110
  10110
  10111
  10101
  01111
  00111
  11100
  10000
  11001
  00010
  01010
EOF
test_example StringIO.open(example) { |io| part1 io }, 198
test_example StringIO.open(example) { |io| part2 io }, 230

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
