#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_io(io)
  line, = io.readlines chomp: true
  line.split(',')
end

def hash_algorithm(command, value = 0)
  command.split('').each do |char|
    value = (17 * (value + char.ord)) % 256
  end
  value
end

def part1(io)
  commands = parse_io io
  hashes = commands.map { |command| hash_algorithm command }
  hashes.sum
end

# Lens
module Lens
  def self.new(label, focal_length)
    { label: label, focal_length: focal_length }
  end

  def self.label(lens)
    lens[:label]
  end

  def self.focal_length(lens)
    lens[:focal_length]
  end

  def self.replace_focal_length(lens, focal_length)
    Lens.new lens[:label], focal_length
  end
end

# Box
module Box
  def self.new
    []
  end

  def self.include?(box, label)
    box.any? { |lens| Lens.label(lens) == label }
  end

  def self.append_lens(box, lens)
    box + [lens]
  end

  def self.replace_lens(box, lens)
    box.map { |boxlens| Lens.label(boxlens) == Lens.label(lens) ? lens : boxlens }
  end

  def self.remove_lens(box, label)
    box.reject { |boxlens| Lens.label(boxlens) == label }
  end

  def self.focusing_power(box)
    powers = box.each_with_index.map do |lens, i|
      (i + 1) * Lens.focal_length(lens)
    end
    powers.sum
  end
end

# Boxes
module Boxes
  def self.new(n)
    Array.new(n) { Box.new }
  end

  def self.get(boxes, hash)
    boxes[hash]
  end

  def self.set(boxes, hash, box)
    boxes.each_with_index.map do |b, i|
      i == hash ? box : b
    end
  end
end

def focusing_power(boxes)
  powers = boxes.each_with_index.map do |box, i|
    (i + 1) * Box.focusing_power(box)
  end
  powers.sum
end

def hashmap_algorithm_equals_operation(boxes, label, focal_length)
  hash = hash_algorithm label
  lens = Lens.new label, focal_length

  box = Boxes.get boxes, hash
  box = if Box.include? box, label
          Box.replace_lens box, lens
        else
          Box.append_lens box, lens
        end
  Boxes.set boxes, hash, box
end

def hashmap_algorithm_dash_operation(boxes, label)
  hash = hash_algorithm label
  box = Boxes.get boxes, hash
  box = Box.remove_lens box, label
  Boxes.set boxes, hash, box
end

def hashmap_algorithm_operation(boxes, command)
  case command
  when /^([a-z]+)=(\d)$/
    label = Regexp.last_match 1
    focal_length = Regexp.last_match(2).to_i
    boxes = hashmap_algorithm_equals_operation boxes, label, focal_length
  when /^([a-z]+)-$/
    label = Regexp.last_match 1
    boxes = hashmap_algorithm_dash_operation boxes, label
  end

  boxes
end

def hashmap_algorithm(commands)
  boxes = Boxes.new 256
  commands.each do |command|
    boxes = hashmap_algorithm_operation boxes, command
  end
  focusing_power boxes
end

def part2(io)
  commands = parse_io io
  hashmap_algorithm commands
end

example = <<~EOF
  rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
EOF
Test.example StringIO.open(example) { |io| part1 io }, 1320
Test.example StringIO.open(example) { |io| part2 io }, 145

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 495_972
Test.solution File.open(input) { |io| part2 io }, 245_223
