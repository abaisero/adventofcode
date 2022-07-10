# frozen_string_literal: true

def read_data(filename)
  lines = File.foreach(filename).map(&:strip)
  index = lines.find_index(&:empty?)
  dots = lines[0...index].map { |line| line.split(',').map(&:to_i) }
  folds = lines[index + 1...]
  [dots, folds]
end

def perform_horizontal_fold(dots, fold_y)
  dots.map { |x, y| [x, y < fold_y ? y : 2 * fold_y - y] }
end

def perform_vertical_fold(dots, fold_x)
  dots.map { |x, y| [x < fold_x ? x : 2 * fold_x - x, y] }
end

def perform_fold(dots, fold)
  m = fold.match(/fold along ([xy])=(\d+)/)
  case m[1]
  when 'x' then perform_vertical_fold(dots, m[2].to_i)
  when 'y' then perform_horizontal_fold(dots, m[2].to_i)
  end
end

def print_dots(dots)
  nrows = dots.map { |_, y| y }.max + 1
  ncols = dots.map { |x, _| x }.max + 1
  matrix = Array.new(nrows) { Array.new(ncols, ' ') }
  dots.each do |x, y|
    matrix[y][x] = '#'
  end
  puts matrix.map(&:join).join("\n")
end

def part1(filename)
  dots, folds = read_data filename
  dots = perform_fold(dots, folds.first)
  dots.uniq.length
end

def part2(filename)
  dots, folds = read_data filename
  folds.each do |fold|
    dots = perform_fold(dots, fold)
  end
  print_dots dots.uniq
end

p part1 '13.example.txt'
p part1 '13.txt'
part2 '13.example.txt'
part2 '13.txt'
