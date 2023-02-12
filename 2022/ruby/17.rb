#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_io(io)
  line, = io.readlines chomp: true
  line.each_char.map(&:to_sym)
end

ROCK_BITLINES = [
  [0b0011110],
  [0b0001000, 0b0011100, 0b0001000],
  [0b0011100, 0b0000100, 0b0000100],
  [0b0010000, 0b0010000, 0b0010000, 0b0010000],
  [0b0011000, 0b0011000]
].freeze

WIDTH = 7
EMPTY_BITLINE = 0b0000000
FULL_BITLINE = 0b1111111
LEFT_BIT = 0b1000000
RIGHT_BIT = 0b0000001

def bitline_to_s(bitline)
  bitline.to_s(2).tr('01', ' #').rjust(WIDTH)
end

# BitMap
class BitMap
  attr_reader :bitlines

  def initialize(bitlines)
    @bitlines = bitlines
  end

  def hash
    @bitlines.hash
  end

  def eql?(other)
    @bitlines == other.bitlines
  end

  def extend_bottom(n)
    BitMap.new [EMPTY_BITLINE] * n + @bitlines
  end

  def extend_top(n)
    BitMap.new @bitlines + [EMPTY_BITLINE] * n
  end

  def height
    @bitlines.length
  end

  def bitbase
    @bitlines.find_index { |bitline| bitline != FULL_BITLINE }
  end

  def bitheight
    height - @bitlines.reverse_each.find_index { |bitline| bitline != EMPTY_BITLINE }
  end

  def clip
    BitMap.new @bitlines[bitbase - 1...bitheight]
  end

  def left_bit?
    @bitlines.any? { |bitline| bitline & LEFT_BIT != EMPTY_BITLINE }
  end

  def right_bit?
    @bitlines.any?(&:odd?)
  end

  def move_bits(direction)
    bitmap = self

    case direction
    when :< then bitmap = move_bits_left unless left_bit?
    when :> then bitmap = move_bits_right unless right_bit?
    when :v then bitmap = move_bits_down
    end
    bitmap
  end

  def move_bits_left
    BitMap.new(@bitlines.map { |bitline| bitline << 1 })
  end

  def move_bits_right
    BitMap.new(@bitlines.map { |bitline| bitline >> 1 })
  end

  def move_bits_down
    BitMap.new @bitlines[1...] << EMPTY_BITLINE
  end

  def collision?(other)
    @bitlines.zip(other.bitlines).any? do |self_bitline, other_bitline|
      self_bitline & other_bitline != EMPTY_BITLINE
    end
  end

  def surface
    surface = [@bitlines.last]
    unreachable = @bitlines.last

    @bitlines.reverse_each do |bitline|
      unreachable |= bitline
      unreachable &= (unreachable << 1) | RIGHT_BIT
      unreachable &= (unreachable >> 1) | LEFT_BIT
      unreachable |= bitline
      unreachable &= FULL_BITLINE
      surface.unshift unreachable
    end

    BitMap.new surface
  end

  def |(other)
    bitlines = @bitlines.zip(other.bitlines).map { |bitline1, bitline2| bitline1 | bitline2 }
    BitMap.new bitlines
  end

  def +(other)
    BitMap.new @bitlines + other.bitlines
  end

  def to_s
    io = StringIO.new
    io.puts '+-------+'
    @bitlines.reverse_each do |bitline|
      io.puts "|#{bitline_to_s bitline}|"
    end
    io.puts '+-------+'
    io.string
  end
end

# Chamber
class Chamber
  attr_reader :bitbase, :bitmap

  def initialize(bitbase, bitmap)
    @bitbase = bitbase
    @bitmap = bitmap
  end

  def bitheight
    @bitbase + @bitmap.bitheight - 1
  end

  def union_bitmap(bitmap)
    Chamber.new @bitbase, @bitmap | bitmap
  end

  def standardize
    surface = @bitmap.surface
    bitbase = @bitbase + surface.bitbase - 1
    Chamber.new bitbase, surface.clip
  end

  def extend_top(n)
    bitmap = @bitmap.extend_top n
    Chamber.new @bitbase, bitmap
  end

  def increase_bitbase(n)
    Chamber.new @bitbase + n, @bitmap
  end
end

def simulate_rock(chamber, rock_id, jet_id, jets)
  rock = BitMap.new ROCK_BITLINES[rock_id]
  rock_height = rock.height
  rock = rock.extend_bottom chamber.bitmap.height + 3
  chamber = chamber.extend_top 3 + rock_height
  raise unless rock.height == chamber.bitmap.height

  loop do
    rock, collision = rock_step chamber, rock, jets[jet_id]
    jet_id = (jet_id + 1) % jets.length
    break if collision
  end

  chamber = chamber.union_bitmap rock
  chamber = chamber.standardize

  [chamber, jet_id]
end

def simulation_skip(chamber, num_rocks, rock_id, jet_id, cache)
  cache_key = [rock_id, jet_id, chamber.bitmap]
  cache_value = {
    num_rocks: num_rocks,
    bitheight: chamber.bitheight
  }

  sim_skip_done = cache.key? cache_key

  if sim_skip_done
    cached_value = cache[cache_key]
    diff_num_rocks = cached_value[:num_rocks] - cache_value[:num_rocks]
    diff_bitheight = cache_value[:bitheight] - cached_value[:bitheight]

    skip_times = num_rocks / diff_num_rocks
    num_rocks -= skip_times * diff_num_rocks
    chamber = chamber.increase_bitbase skip_times * diff_bitheight
  else
    cache[cache_key] = cache_value
  end

  [chamber, num_rocks, sim_skip_done]
end

def simulate_rocks(jets, num_rocks)
  chamber = Chamber.new 0, BitMap.new([FULL_BITLINE])
  rock_id = 0
  jet_id = 0

  sim_cache = {}
  sim_skip_done = false
  while num_rocks.positive?
    unless sim_skip_done
      chamber, num_rocks, sim_skip_done = simulation_skip chamber, num_rocks, rock_id, jet_id, sim_cache
    end
    chamber, jet_id = simulate_rock chamber, rock_id, jet_id, jets
    rock_id = (rock_id + 1) % ROCK_BITLINES.length
    num_rocks -= 1
  end

  chamber.bitheight
end

def rock_step_jet(chamber, rock, jet)
  rock_candidate = rock.move_bits jet
  rock = rock_candidate unless chamber.bitmap.collision? rock_candidate
  rock
end

def rock_step_fall(chamber, rock)
  rock_candidate = rock.move_bits :v
  collision = chamber.bitmap.collision? rock_candidate
  rock = rock_candidate unless collision
  [rock, collision]
end

def rock_step(chamber, rock, jet)
  rock = rock_step_jet chamber, rock, jet
  rock, collision = rock_step_fall chamber, rock
  [rock, collision]
end

def part1(io)
  jets = parse_io io
  simulate_rocks jets, 2022
end

def part2(io)
  jets = parse_io io
  simulate_rocks jets, 1_000_000_000_000
end

example = '>>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>'
Test.example StringIO.open(example) { |io| part1 io }, 3068
Test.example StringIO.open(example) { |io| part2 io }, 1_514_285_714_288

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 3067
Test.solution File.open(input) { |io| part2 io }, 1_514_369_501_484
