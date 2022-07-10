# frozen_string_literal: true

def read_data(filename)
  File.foreach(filename).map do |line|
    m = line.strip.match(/^(?<x1>\d+),(?<y1>\d+) -> (?<x2>\d+),(?<y2>\d+)$/)
    {
      vertical: m[:x1] == m[:x2],
      horizontal: m[:y1] == m[:y2],
      xs: [m[:x1].to_i, m[:x2].to_i],
      ys: [m[:y1].to_i, m[:y2].to_i]
    }
  end
end

def bidirectional_range(range)
  # takes a range and inverts it if empty
  range.first <= range.last ? range : range.last..range.first
end

def compute_coordinates(vent)
  xs = vent[:xs]
  ys = vent[:ys]

  return xs.min.upto(xs.max).map { |x| [x, ys.sample] } if vent[:horizontal]
  return ys.min.upto(ys.max).map { |y| [xs.sample, y] } if vent[:vertical]

  xrange = bidirectional_range(xs.first..xs.last)
  yrange = bidirectional_range(ys.first..ys.last)
  xrange.zip(yrange).to_a
end

def count_vent_overlaps(vents)
  coordinates = vents.map { |vent| compute_coordinates vent }
  coordinates.flatten! 1

  xmax = coordinates.map(&:first).max
  ymax = coordinates.map(&:last).max
  field = Array.new(ymax + 1) { Array.new(xmax + 1, 0) }

  coordinates.each { |x, y| field[y][x] += 1 }
  field.flatten.count { |value| value >= 2 }
end

def part1(filename)
  vents = read_data filename
  vents = vents.select { |vent| vent[:horizontal] or vent[:vertical] }
  count_vent_overlaps vents
end

def part2(filename)
  vents = read_data filename
  count_vent_overlaps vents
end

p part1 '05.example.txt'
p part1 '05.txt'
p part2 '05.example.txt'
p part2 '05.txt'
