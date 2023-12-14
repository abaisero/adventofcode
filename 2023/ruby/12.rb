#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_io_line(line)
  record, checksum = line.split ' '
  record = record.chars
  checksum = checksum.scan(/\d+/).map(&:to_i)
  [record, checksum]
end

def parse_io(io)
  lines = io.readlines chomp: true
  lines.map { |line| parse_io_line line }
end

def overwrite_first(record, value)
  raise record.to_s if record.first != value && record.first != '?'

  [value] + record[1...]
end

def compatible?(sequence, values)
  sequence.all? { |tile| values.include? tile }
end

def compatible_damaged?(record, checksum)
  n = checksum.first

  return false unless compatible?(record[...n], ['#', '?'])
  return true if record.length == n

  compatible?([record[n]], ['.', '?'])
end

def count_configurations_damaged(record, checksum, cache)
  return 0 unless compatible_damaged? record, checksum

  record = record[checksum.first...]
  checksum = checksum[1...]

  unless record.empty?
    return 0 if record.first == '#'

    record = overwrite_first record, '.'
  end

  count_configurations record, checksum, cache
end

def count_configurations_operational(record, checksum, cache)
  record = record.drop_while { |tile| tile == '.' }
  count_configurations record, checksum, cache
end

def count_configurations_unknown(record, checksum, cache)
  damaged_record = overwrite_first record, '#'
  count_damaged = count_configurations damaged_record, checksum, cache

  operational_record = overwrite_first record, '.'
  count_operational = count_configurations operational_record, checksum, cache

  count_damaged + count_operational
end

def count_configurations_empty_record(checksum)
  checksum.empty? ? 1 : 0
end

def count_configurations_empty_checksum(record)
  compatible?(record, ['.', '?']) ? 1 : 0
end

def count_configurations_explicit(record, checksum, cache)
  return count_configurations_empty_record(checksum) if record.empty?
  return count_configurations_empty_checksum(record) if checksum.empty?
  return 0 if record.length < checksum.sum + checksum.length - 1

  case record.first
  when '#' then count_configurations_damaged record, checksum, cache
  when '.' then count_configurations_operational record, checksum, cache
  when '?' then count_configurations_unknown record, checksum, cache
  end
end

def count_configurations(record, checksum, cache = nil)
  cache = {} if cache.nil?
  cache[[record, checksum]] ||= count_configurations_explicit record, checksum, cache
end

def part1(io)
  data = parse_io io
  configurations = data.map do |record, checksum|
    count_configurations record, checksum
  end
  configurations.sum
end

def unfold(record, checksum)
  record = ((record + ['?']) * 5)[...-1]
  checksum *= 5
  [record, checksum]
end

def part2(io)
  data = parse_io io
  configurations = data.map do |record, checksum|
    record, checksum = unfold record, checksum
    count_configurations record, checksum
  end
  configurations.sum
end

example = <<~EOF
  ???.### 1,1,3
  .??..??...?##. 1,1,3
  ?#?#?#?#?#?#?#? 1,3,1,6
  ????.#...#... 4,1,1
  ????.######..#####. 1,6,5
  ?###???????? 3,2,1
EOF
Test.example StringIO.open(example) { |io| part1 io }, 21
Test.example StringIO.open(example) { |io| part2 io }, 525_152

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 7032
Test.solution File.open(input) { |io| part2 io }, 1_493_340_882_140
