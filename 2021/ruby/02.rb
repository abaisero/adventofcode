# frozen_string_literal: true

def read_data(filename)
  File.foreach(filename).map do |line|
    m = line.strip.match(/^(?<command>\w+)\s+(?<value>\d+)$/)
    command = m[:command].to_sym
    value = m[:value].to_i
    [command, value]
  end
end

def part1(filename)
  data = read_data filename

  state = { position: 0, depth: 0 }
  data.each do |command, value|
    case command
    when :forward then state[:position] += value
    when :down then state[:depth] += value
    when :up then state[:depth] -= value
    end
  end
  state[:position] * state[:depth]
end

def part2(filename)
  data = read_data filename

  state = { position: 0, depth: 0, aim: 0 }
  data.each do |command, value|
    case command
    when :forward
      state[:position] += value
      state[:depth] += state[:aim] * value
    when :down then state[:aim] += value
    when :up then state[:aim] -= value
    end
  end
  state[:position] * state[:depth]
end

p part1 '02.example.txt'
p part1 '02.txt'
p part2 '02.example.txt'
p part2 '02.txt'
