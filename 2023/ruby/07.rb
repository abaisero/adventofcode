#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_io_line(line)
  cards = line[...5].chars
  bid = line[6...].to_i
  { cards: cards, bid: bid }
end

def parse_io(io)
  lines = io.readlines chomp: true
  lines.map { |line| parse_io_line line }
end

def compute_hand_type1(hand)
  counts = hand[:counts].values.sort.reverse
  case counts[0]
  when 5 then :five
  when 4 then :four
  when 3 then counts[1] == 2 ? :fullhouse : :three
  when 2 then counts[1] == 2 ? :twopair : :pair
  when 1 then :high
  end
end

def compute_winnings(hands, card_ranks)
  hands = hands.sort { |hand1, hand2| hand_sort hand1, hand2, card_ranks }
  winnings = hands.reverse.map.with_index { |hand, index| hand[:bid] * (index + 1) }
  winnings.sum
end

HAND_TYPE_RANKS = %i[five four fullhouse three twopair pair high].freeze

def hand_sort_by_type(hand1, hand2)
  rank1 = HAND_TYPE_RANKS.index(hand1[:type])
  rank2 = HAND_TYPE_RANKS.index(hand2[:type])
  rank1 <=> rank2
end

def hand_sort_by_cards(hand1, hand2, card_ranks)
  ranks1 = hand1[:cards].map { |card| card_ranks.index card }
  ranks2 = hand2[:cards].map { |card| card_ranks.index card }
  ranks1 <=> ranks2
end

def hand_sort(hand1, hand2, card_ranks)
  if hand1[:type] != hand2[:type]
    hand_sort_by_type hand1, hand2
  elsif hand1[:cards] != hand2[:cards]
    hand_sort_by_cards hand1, hand2, card_ranks
  else
    0
  end
end

def part1(io)
  hands = parse_io io
  hands.each do |hand|
    hand[:counts] = hand[:cards].tally
    hand[:type] = compute_hand_type1 hand
  end

  card_ranks = 'AKQJT98765432'.chars.freeze
  compute_winnings hands, card_ranks
end

def compute_hand_type2(hand)
  counts = hand[:counts].clone
  jokers = counts.fetch('J', 0)
  counts.delete 'J'
  counts = counts.values.sort.reverse

  return :five if counts.empty?

  case counts.first + jokers
  when 5 then :five
  when 4 then :four
  when 3 then counts[1] == 2 ? :fullhouse : :three
  when 2 then counts[1] == 2 ? :twopair : :pair
  when 1 then :high
  end
end

def part2(io)
  hands = parse_io io
  hands.each do |hand|
    hand[:counts] = hand[:cards].tally
    hand[:type] = compute_hand_type2 hand
  end

  card_ranks = 'AKQT98765432J'.chars.freeze
  compute_winnings hands, card_ranks
end

example = <<~EOF
  32T3K 765
  T55J5 684
  KK677 28
  KTJJT 220
  QQQJA 483
EOF
Test.example StringIO.open(example) { |io| part1 io }, 6440
Test.example StringIO.open(example) { |io| part2 io }, 5905

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 248_453_531
Test.solution File.open(input) { |io| part2 io }, 248_781_813
