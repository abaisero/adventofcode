# frozen_string_literal: true

def read_data(filename)
  File.readlines(filename).join.strip.split(',').map(&:to_i)
end

def run_epoch(fish)
  new_fish = fish.shift
  fish[6] += new_fish
  fish.append new_fish
end

def num_fish_after_epochs(fish, num_epochs)
  fish = (0..8).map { |t| fish.count t }
  num_epochs.times { run_epoch fish }
  fish.sum
end

def part1(filename)
  fish = read_data filename
  num_fish_after_epochs(fish, 80)
end

def part2(filename)
  fish = read_data filename
  num_fish_after_epochs(fish, 256)
end

p part1 '06.example.txt'
p part1 '06.txt'
p part2 '06.example.txt'
p part2 '06.txt'
