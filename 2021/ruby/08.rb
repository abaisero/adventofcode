#!/usr/bin/env ruby
# frozen_string_literal: true

def read_data(filename)
  File.foreach(filename).map do |line|
    line = line.split('|')
    {
      digits: line[0].split,
      code: line[1].split
    }
  end
end

def part1(filename)
  data = read_data filename

  # number of segments for digits 1, 4, 7, 8 (which respectively have 2, 4, 3, 7 segments)
  lengths = [2, 4, 3, 7]
  data.map { |d| d[:code] }.flatten.map(&:length).count { |l| lengths.include? l }
end

def part2(filename)
  data = read_data filename

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

p part1 '08.example.txt'
p part1 '08.txt'
p part2 '08.example.txt'
p part2 '08.txt'
