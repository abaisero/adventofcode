#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'data_stack'
require_relative 'test'

module Sequence
  def self.new(sequence)
    sequence
  end

  def self.subsequence(sequence, start_index, sequence_length)
    end_index = start_index + sequence_length
    Sequence.new sequence[start_index...end_index]
  end

  def self.uniq?(sequence)
    sequence.length == sequence.chars.uniq.length
  end
end

def parse_io(io)
  lines = io.readlines chomp: true
  signal, = lines
  Sequence.new signal
end

module SignalOperations
  def self.start_of_packet?(sequence)
    Sequence.uniq? sequence
  end

  def self.find_start_of_packet_index(signal, marker_length)
    (0...).find do |index|
      sequence = Sequence.subsequence signal, index, marker_length
      SignalOperations.start_of_packet? sequence
    end
  end

  def self.find_packet_content_index(signal, marker_length)
    index = SignalOperations.find_start_of_packet_index signal, marker_length
    index + marker_length
  end
end

def part1(io)
  signal = parse_io io
  SignalOperations.find_packet_content_index signal, 4
end

def part2(io)
  signal = parse_io io
  SignalOperations.find_packet_content_index signal, 14
end

example = 'mjqjpqmgbljsphdztnvjfqwrcgsmlb'
Test.example StringIO.open(example) { |io| part1 io }, 7
Test.example StringIO.open(example) { |io| part2 io }, 19

example = 'bvwbjplbgvbhsrlpgdmjqwftvncz'
Test.example StringIO.open(example) { |io| part1 io }, 5
Test.example StringIO.open(example) { |io| part2 io }, 23

example = 'nppdvjthqldpwncqszvftbrmjlhg'
Test.example StringIO.open(example) { |io| part1 io }, 6
Test.example StringIO.open(example) { |io| part2 io }, 23

example = 'nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg'
Test.example StringIO.open(example) { |io| part1 io }, 10
Test.example StringIO.open(example) { |io| part2 io }, 29

example = 'zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw'
Test.example StringIO.open(example) { |io| part1 io }, 11
Test.example StringIO.open(example) { |io| part2 io }, 26

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 1210
Test.solution File.open(input) { |io| part2 io }, 3476
