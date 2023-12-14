#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_games(games)
  games.split('; ').map do |game|
    game.scan(/(\d+) (red|green|blue)/).map do |n, color|
      n = n.to_i
      color = color.to_sym
      [color, n]
    end.to_h
  end
end

def parse_io_line(line)
  line.match(/^Game (\d+): (.+)$/) do |match|
    id, games = match.captures
    id = id.to_i
    games = parse_games games
    [id, games]
  end
end

def parse_io(io)
  lines = io.readlines chomp: true
  lines.map { |line| parse_io_line line }
end

BAG = { red: 12, green: 13, blue: 14 }.freeze

def game_possible?(cubes)
  BAG.all? { |key, value| cubes.fetch(key, 0) <= value }
end

def part1(io)
  games = parse_io io
  ids = games.filter_map { |id, sets| id if sets.all? { |cubes| game_possible? cubes } }
  ids.sum
end

def combine_cubes(x, y)
  %i[red green blue].map do |color|
    count = [x.fetch(color, 0), y.fetch(color, 0)].max
    [color, count]
  end.to_h
end

def part2(io)
  games = parse_io io
  powers = games.map do |_, sets|
    cubes = sets.reduce { |x, y| combine_cubes x, y }
    cubes[:red] * cubes[:green] * cubes[:blue]
  end
  powers.sum
end

example = <<~EOF
  Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
  Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
  Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
  Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
  Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
EOF
Test.example StringIO.open(example) { |io| part1 io }, 8
Test.example StringIO.open(example) { |io| part2 io }, 2286

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 2913
Test.solution File.open(input) { |io| part2 io }, 55_593
