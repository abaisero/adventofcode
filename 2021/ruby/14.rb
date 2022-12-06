#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

PADDING = '.'
def parse_data(io)
  lines = io.map(&:chomp)
  template = "#{PADDING}#{lines.first}#{PADDING}".split('')
  rules = lines[2..].map { |line| [line[0], line[1], line[-1]] }
  [template, rules]
end

def make_paircounts(template, rules)
  letters = (template + rules.flatten).uniq.sort
  paircounts = letters.product(letters).map { |a, b| [[a, b], 0] }.to_h
  template.each_cons(2).each do |a, b|
    paircounts[[a, b]] += 1
  end
  paircounts
end

def run_step(paircounts, rules)
  old_paircounts = paircounts.dup
  rules.each do |a, b, c|
    paircounts[[a, b]] -= old_paircounts[[a, b]]
    paircounts[[a, c]] += old_paircounts[[a, b]]
    paircounts[[c, b]] += old_paircounts[[a, b]]
  end
end

def score(paircounts)
  letters = paircounts.keys.flatten.uniq - [PADDING]
  # only count the times a letter appears at the beginning of a pair
  counts = letters.map { |l| paircounts.select { |k, _| k[0] == l }.values.sum }
  counts.max - counts.min
end

def part1(io)
  template, rules = parse_data io
  paircounts = make_paircounts(template, rules)
  10.times { run_step(paircounts, rules) }
  score paircounts
end

def part2(io)
  template, rules = parse_data io
  paircounts = make_paircounts(template, rules)
  40.times { run_step(paircounts, rules) }
  score paircounts
end

example = <<~EOF
  NNCB

  CH -> B
  HH -> N
  CB -> H
  NH -> C
  HB -> C
  HC -> B
  HN -> C
  NN -> C
  BH -> H
  NC -> B
  NB -> B
  BN -> B
  BB -> N
  BC -> B
  CC -> N
  CN -> C
EOF
test_example StringIO.open(example) { |io| part1 io }, 1588
test_example StringIO.open(example) { |io| part2 io }, 2_188_189_693_529

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
