# frozen_string_literal: true

def read_data(filename)
  File.foreach(filename).map { |line| line.strip.split('-') }
end

def start?(cave)
  cave == 'start'
end

def end?(cave)
  cave == 'end'
end

def small?(cave)
  ('a'..'z').include? cave[0]
end

def big?(cave)
  ('A'..'Z').include? cave[0]
end

def add_link(cavehash, from, to)
  return if end?(from) || start?(to)

  cavehash[from] = [] unless cavehash.include? from
  cavehash[from] << to
end

def make_cavehash(connections)
  cavehash = {}
  connections.each do |from, to|
    add_link(cavehash, from, to)
    add_link(cavehash, to, from)
  end
  cavehash
end

def find_paths1(cavehash, path = ['start'], paths = [])
  if end? path.last
    paths << path
    return
  end

  cavehash[path.last].each do |cave|
    next if small?(cave) && path.include?(cave)

    find_paths1(cavehash, path + [cave], paths)
  end

  paths
end

def part1(filename)
  connections = read_data filename
  cavehash = make_cavehash connections
  paths = find_paths1 cavehash
  paths.length
end

def already_double_visited_small(path)
  small_caves = path.select { |cave| small? cave }
  small_caves.length != small_caves.uniq.length
end

def find_paths2(cavehash, path = ['start'], paths = [])
  if end? path.last
    paths << path
    return
  end

  cavehash[path.last].each do |cave|
    next if small?(cave) && path.include?(cave) && already_double_visited_small(path)

    find_paths2(cavehash, path + [cave], paths)
  end

  paths
end

def part2(filename)
  connections = read_data filename
  cavehash = make_cavehash connections
  paths = find_paths2 cavehash
  paths.length
end

p part1 '12.example.txt'
p part1 '12.txt'
p part2 '12.example.txt'
p part2 '12.txt'
