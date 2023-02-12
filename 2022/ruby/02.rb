#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_io_line(line)
  line.split.map(&:to_sym)
end

def parse_io(io)
  lines = io.readlines chomp: true
  lines.map { |line| parse_io_line line }
end

SHAPE_SCORE = { rock: 1, paper: 2, scissors: 3 }.freeze

def shape_score(move)
  SHAPE_SCORE[move]
end

MOVES = %i[rock paper scissors].freeze

def move_id(move)
  MOVES.index move
end

def outcome_from_ids(opponent_id, response_id)
  (response_id - opponent_id + 1) % 3 - 1
end

def outcome_from_moves(opponent_move, response_move)
  opponent_id = move_id opponent_move
  response_id = move_id response_move
  outcome_from_ids opponent_id, response_id
end

def outcome_score(opponent_move, response_move)
  outcome = outcome_from_moves opponent_move, response_move
  3 * (outcome + 1)
end

def score(opponent_move, response_move)
  shape_score(response_move) + outcome_score(opponent_move, response_move)
end

def score_moves(moves)
  moves.map { |opponent_move, response_move| score opponent_move, response_move }.sum
end

OPPONENT_CODE_TO_MOVE = { A: :rock, B: :paper, C: :scissors }.freeze

def convert_opponent_code_to_move(opponent_code)
  OPPONENT_CODE_TO_MOVE[opponent_code]
end

RESPONSE_CODE_TO_MOVE = { X: :rock, Y: :paper, Z: :scissors }.freeze

def convert_response_code_to_move(response_code)
  RESPONSE_CODE_TO_MOVE[response_code]
end

def convert_guide_part1(opponent_code, response_code)
  opponent_move = convert_opponent_code_to_move opponent_code
  response_move = convert_response_code_to_move response_code
  [opponent_move, response_move]
end

def convert_guide(guide, conversion)
  guide.map { |codes| conversion.call(*codes) }
end

def part1(io)
  guide = parse_io io
  conversion_function = method :convert_guide_part1
  moves = convert_guide guide, conversion_function
  score_moves moves
end

WINNING_RESPONSE = { rock: :paper, paper: :scissors, scissors: :rock }.freeze

def winning_response(move)
  WINNING_RESPONSE[move]
end

LOSING_RESPONSE = { rock: :scissors, paper: :rock, scissors: :paper }.freeze

def losing_response(move)
  LOSING_RESPONSE[move]
end

def convert_goal_to_move(opponent_move, goal)
  case goal
  when :X then losing_response opponent_move
  when :Y then opponent_move
  when :Z then winning_response opponent_move
  end
end

def convert_guide_part2(opponent_code, goal_code)
  opponent_move = convert_opponent_code_to_move opponent_code
  response_move = convert_goal_to_move opponent_move, goal_code

  [opponent_move, response_move]
end

def part2(io)
  guide = parse_io io
  conversion_function = method :convert_guide_part2
  moves = convert_guide guide, conversion_function
  score_moves moves
end

example = <<~EOF
  A Y
  B X
  C Z
EOF
Test.example StringIO.open(example) { |io| part1 io }, 15
Test.example StringIO.open(example) { |io| part2 io }, 12

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 9241
Test.solution File.open(input) { |io| part2 io }, 14_610
