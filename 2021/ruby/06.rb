#!/usr/bin/env ruby
# frozen_string_literal: true

def read_data(filename)
  File.readlines(filename).join.strip.split(',').map(&:to_i)
end

def initial_fishcounts(fish)
  (0..8).map { |n| fish.count n }
end

def updated_fishcounts(fishcounts)
  fishcounts = fishcounts.rotate
  fishcounts[6] += fishcounts.last
  fishcounts
end

def nfish_after_ndays(fish, ndays)
  fishcounts = initial_fishcounts fish
  ndays.times do
    fishcounts = updated_fishcounts fishcounts
  end
  fishcounts.sum
end

def part1(filename)
  fish = read_data filename
  nfish_after_ndays fish, 80
end

def part2(filename)
  fish = read_data filename
  nfish_after_ndays fish, 256
end

p part1 '06.example.txt'
p part1 '06.txt'
p part2 '06.example.txt'
p part2 '06.txt'
