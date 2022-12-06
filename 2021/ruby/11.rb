#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'
require_relative 'utils'

def parse_data(io)
  io.map { |line| line.chomp.each_char.map(&:to_i) }
end

def increase_energies(matrix)
  matrix.each do |row|
    row.each_index do |j|
      row[j] += 1
    end
  end
end

def settle_energies(matrix)
  matrix.each do |row|
    row.map! { |x| x || 0 }
  end
end

def neighbor_indices(index_i, index_j)
  deltas = [-1, 0, 1].product([-1, 0, 1]).reject { |di, dj| di.zero? && dj.zero? }
  apply_indices_deltas(index_i, index_j, deltas)
end

def valid_neighbor_indices(energies, index_i, index_j)
  neighbor_indices(index_i, index_j).select { |i, j| valid_indices?(energies, i, j) }
end

def flash(energies, index_i, index_j)
  energies[index_i][index_j] = nil

  valid_neighbor_indices(energies, index_i, index_j).each do |i, j|
    next if energies[i][j].nil?

    energies[i][j] += 1
    flash(energies, i, j) if energies[i][j] > 9
  end
end

def propagate_flashes(energies)
  energies.each.with_index do |row, i|
    row.each.with_index do |energy, j|
      next if energy.nil?

      flash(energies, i, j) if energy > 9
    end
  end
end

def step(energies)
  increase_energies energies
  propagate_flashes energies
  num_flashes = energies.flatten.count(&:nil?)
  settle_energies energies
  num_flashes
end

def part1(io)
  energies = parse_data io
  100.times.map { step energies }.sum
end

def part2(io)
  energies = parse_data io
  goal_flashes = energies.length * energies.first.length

  (1...).find do
    num_flashes = step energies
    num_flashes == goal_flashes
  end
end

example = <<~EOF
  5483143223
  2745854711
  5264556173
  6141336146
  6357385478
  4167524645
  2176841721
  6882881134
  4846848554
  5283751526
EOF
test_example StringIO.open(example) { |io| part1 io }, 1656
test_example StringIO.open(example) { |io| part2 io }, 195

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
