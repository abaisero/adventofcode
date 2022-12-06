#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_data(io)
  io.map do |line|
    line = line.split('|')
    {
      digits: line[0].split,
      code: line[1].split
    }
  end
end

def part1(io)
  data = parse_data io

  # number of segments for digits 1, 4, 7, 8 (which respectively have 2, 4, 3, 7 segments)
  lengths = [2, 4, 3, 7]
  data.map { |d| d[:code] }.flatten.map(&:length).count { |l| lengths.include? l }
end

def part2(io)
  data = parse_data io

  data.map do |d|
    digits = Array.new(10)
    segments = Array.new(7)

    digit_counts = d[:digits].join.split('').group_by(&:itself).map { |k, v| [k, v.length] }
    segments[1] = digit_counts.find { |_, v| v == 6 }.first
    segments[4] = digit_counts.find { |_, v| v == 4 }.first
    segments[5] = digit_counts.find { |_, v| v == 9 }.first

    digits[1] = d[:digits].find { |digit| digit.length == 2 }.split('').sort.join
    digits[4] = d[:digits].find { |digit| digit.length == 4 }.split('').sort.join
    digits[7] = d[:digits].find { |digit| digit.length == 3 }.split('').sort.join
    digits[8] = d[:digits].find { |digit| digit.length == 7 }.split('').sort.join

    segments[0] = (digits[7].split('') - digits[1].split('')).first
    segments[2] = (digits[7].split('') - [segments[0], segments[5]]).first
    segments[3] = (digits[4].split('') - [segments[1], segments[2], segments[5]]).first
    segments[6] = ('a'.upto('g').to_a - segments).first

    get_segment = proc { |i| segments[i] }
    digits[0] = [0, 1, 2, 4, 5, 6].map(&get_segment).sort.join
    digits[2] = [0, 2, 3, 4, 6].map(&get_segment).sort.join
    digits[3] = [0, 2, 3, 5, 6].map(&get_segment).sort.join
    digits[5] = [0, 1, 3, 5, 6].map(&get_segment).sort.join
    digits[6] = [0, 1, 3, 4, 5, 6].map(&get_segment).sort.join
    digits[9] = [0, 1, 2, 3, 5, 6].map(&get_segment).sort.join

    code = d[:code].map { |c| digits.find_index(c.split('').sort.join) }
    1000 * code[0] + 100 * code[1] + 10 * code[2] + code[3]
  end.sum
end

example = <<~EOF
  be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
  edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
  fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
  fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
  aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
  fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
  dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
  bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
  egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
  gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
EOF
test_example StringIO.open(example) { |io| part1 io }, 26
test_example StringIO.open(example) { |io| part2 io }, 61_229

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
