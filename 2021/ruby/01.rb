# frozen_string_literal: true

def read_data(filename)
  File.foreach(filename).map { |line| line.strip.to_i }
end

def count_increasing(array)
  array.each_cons(2).count { |a, b| a < b }
end

def part1(filename)
  data = read_data filename
  count_increasing data
end

def part2(filename)
  data = read_data filename
  data = data.each_cons(3).map { |x, y, z| x + y + z }
  count_increasing data
end

p part1 '01.example.txt'
p part1 '01.txt'
p part2 '01.example.txt'
p part2 '01.txt'
