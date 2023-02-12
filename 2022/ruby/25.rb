#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

SNAFU_DIGIT_TO_INT_DIGIT = {
  '2' => 2,
  '1' => 1,
  '0' => 0,
  '-' => -1,
  '=' => -2
}

INT_DIGIT_TO_SNAFU_DIGIT = SNAFU_DIGIT_TO_INT_DIGIT.invert

def parse_data(io)
  io.map(&:chomp)
end

def snafu_to_int(snafu)
  digits = snafu.chars.map(&SNAFU_DIGIT_TO_INT_DIGIT)
  digits.reverse.map.with_index { |x, i| x * 5**i }.sum
end

def int_to_snafu(number)
  return '0' if number.zero?

  snafu_digits = []
  until number.zero?
    snafu_digits << (number + 2) % 5 - 2
    number = number.fdiv(5).round
  end
  snafu_digits.reverse.map(&INT_DIGIT_TO_SNAFU_DIGIT).join
end

def part1(io)
  snafus = parse_data io
  total = snafus.map { |snafu| snafu_to_int snafu }.sum
  int_to_snafu total
end

def part2(io)
  parse_data io
end

example = <<~EOF
  1=-0-2
  12111
  2=0=
  21
  2=01
  111
  20012
  112
  1=-1=
  1-12
  12
  1=
  122
EOF
Test.example StringIO.open(example) { |io| part1 io }, '2=-1=0'
# Test.example StringIO.open(example) { |io| part2 io }, nil

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, '2-0==21--=0==2201==2'
# Test.solution File.open(input) { |io| part2 io }, nil
