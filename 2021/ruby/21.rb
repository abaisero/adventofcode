#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_data(io)
  io.map { |line| line.split.last.to_i }
end

def canonical(position)
  (position - 1) % 10 + 1
end

def init_player(position)
  { position: position, points: 0 }
end

def play_turn(player, roll)
  player[:position] = canonical player[:position] + roll
  player[:points] += player[:position]
end

def play_game(players)
  nrolls = 0
  rolls = (1..100).cycle(100).each_slice(3).map(&:sum)
  players.cycle.zip(rolls) do |player, roll|
    play_turn player, roll
    nrolls += 3
    break if player[:points] >= 1000
  end
  nrolls
end

def part1(io)
  positions = parse_data io
  players = positions.map { |position| init_player position }
  nrolls = play_game players
  points = players.map { |player| player[:points] }
  points.min * nrolls
end

def init_universes(position)
  universes = Hash.new(0)
  universes[[0, position, 0]] = 1
  universes
end

def compute_universes(position)
  universes = init_universes(position)
  # counting the number of universes in which the player reaches [#turns, #position, #points] (without having already reached the goal in a previous turn

  turns = (1..21).to_a
  positions = (1..10).to_a
  points = (1..30).to_a

  turns.each do |turn|
    positions.each do |pos|
      points.each do |point|
        next unless point - pos < 21

        value = universes[[turn - 1, canonical(pos - 3), point - pos]] \
          + 3 * universes[[turn - 1, canonical(pos - 4), point - pos]] \
          + 6 * universes[[turn - 1, canonical(pos - 5), point - pos]] \
          + 7 * universes[[turn - 1, canonical(pos - 6), point - pos]] \
          + 6 * universes[[turn - 1, canonical(pos - 7), point - pos]] \
          + 3 * universes[[turn - 1, canonical(pos - 8), point - pos]] \
          + 1 * universes[[turn - 1, canonical(pos - 9), point - pos]]

        universes[[turn, pos, point]] = value if value.positive?
      end
    end
  end

  #   positions.each do |pos|
  #     p [pos, universes[[9, pos, 20]]]
  #   end

  total_universes_per_turn = {}
  turns.each do |turn|
    v = positions.sum { |pos| points.sum { |point| universes[[turn, pos, point]] } }
    total_universes_per_turn[turn] = v
  end
  p total_universes_per_turn

  points_done = (21..30)
  universes_done = turns.map do |turn|
    n = positions.sum { |pos| points_done.sum { |point| universes[[turn, pos, point]] } }
    [turn, n]
  end.to_h

  p universes_done
end

def count_wins(x, y)
  xturns = x.keys.select { |turn| x[turn].positive? }
  yturns = y.keys.select { |turn| y[turn].positive? }
  winning_turns = xturns.product(yturns).select { |turn1, turn2| turn1 <= turn2 }
  winning_turns.sum { |turn1, turn2| x[turn1] * y[turn2] }
end

def part2(io)
  positions = parse_data io
  universes = positions.map { |position| compute_universes position }

  wins = [
    count_wins(*universes),
    count_wins(*universes.reverse)
  ]
  p wins
  wins.max
end

example = <<~EOF
  Player 1 starting position: 4
  Player 2 starting position: 8
EOF
test_example StringIO.open(example) { |io| part1 io }, 739_785
test_example StringIO.open(example) { |io| part2 io }, 444_356_092_776_315

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
