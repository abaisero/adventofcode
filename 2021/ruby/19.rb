#!/usr/bin/env ruby
# frozen_string_literal: true

def read_data(filename)
  scanners = []
  File.foreach(filename) do |line|
    case line.strip
    when /^--- scanner \d+ ---$/ then scanners << []
    when /^-?\d+(,-?\d+)*$/ then scanners.last << line.split(',').map(&:to_i)
    end
  end
  scanners
end

def distance(beacon1, beacon2)
  # beacon1.zip(beacon2).map { |x, y| (x - y).abs }
  beacon1.zip(beacon2).map { |x, y| (x - y).abs }.sum
end

def print_matrix(matrix)
  puts matrix.map(&:inspect)
end

def part1(filename)
  scanners = read_data filename
  # scanner = scanners.first
  # beacon = scanner.first
  # pp scanner
  # pp scanner[1...].map { |b| distance beacon, b }

  beacons = scanners.flat_map(&:itself)
  dmatrices = scanners.map { |scanner| scanner.map { |b1| scanner.map { |b2| distance b1, b2 } } }
  pp 'SCANNER 0'
  print_matrix dmatrices[0]
  pp 'SCANNER 1'
  print_matrix dmatrices[1]
  nil
end

def part2(filename)
  scanners = read_data filename
  pp scanners
end

p part1 '19.example.txt'
# p part1 '19.txt'
# p part2 '19.example.txt'
# p part2 '19.txt'
