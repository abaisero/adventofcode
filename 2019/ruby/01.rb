#!/usr/bin/env ruby
# frozen_string_literal: true

def read_data(filename)
  File.foreach(filename).map(&:to_i)
end

def compute_fuel1(mass)
  mass / 3 - 2
end

def part1(filename)
  masses = read_data filename
  masses.map { |mass| compute_fuel1 mass }.sum
end

def compute_fuel2(mass)
  fuel = compute_fuel1 mass
  return 0 unless fuel.positive?

  fuel + compute_fuel2(fuel)
end

def part2(filename)
  masses = read_data filename
  masses.map { |mass| compute_fuel2 mass }.sum
end

raise unless compute_fuel1(12) == 2
raise unless compute_fuel1(14) == 2
raise unless compute_fuel1(1969) == 654
raise unless compute_fuel1(100_756) == 33_583

raise unless compute_fuel2(14) == 2
raise unless compute_fuel2(1969) == 966
raise unless compute_fuel2(100_756) == 50_346

p part1 '01.txt'
p part2 '01.txt'
