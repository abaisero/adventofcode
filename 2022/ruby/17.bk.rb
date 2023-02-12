#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_data(io)
  io.read.chomp.each_char.map(&:to_sym)
end

ROCK_SPRITES = [
  [%i[# # # #]],
  [
    %i[. # .],
    %i[# # #],
    %i[. # .]
  ],
  [
    %i[. . #],
    %i[. . #],
    %i[# # #]
  ],
  [
    %i[#],
    %i[#],
    %i[#],
    %i[#]
  ],
  [
    %i[# #],
    %i[# #]
  ]
].freeze

CHAMBER_WIDTH = 7

def init_chamber
  CHAMBER_WIDTH.times.map { |x| [x, 0] }
end

ROCKS = [
  [[0, 0], [1, 0], [2, 0], [3, 0]],
  [[1, 0], [0, 1], [1, 1], [2, 1], [1, 2]],
  [[0, 0], [1, 0], [2, 0], [2, 1], [2, 2]],
  [[0, 0], [0, 1], [0, 2], [0, 3]],
  [[0, 0], [0, 1], [1, 0], [1, 1]]
].freeze

def init_rock_anchor(chamber)
  # rock anchor is based on the bottom left corner of the sprite
  y = chamber.map { |_, y| y }.max + 4
  [2, y]
end

def init_rock(chamber, rock_id)
  x, y = init_rock_anchor chamber
  ROCKS[rock_id].map { |dx, dy| [x + dx, y + dy] }
end

def compute_chamber_heights(chamber)
  heights = chamber.group_by { |x, _| x }.transform_values { |points| points.map { |_, y| y }.max }
  CHAMBER_WIDTH.times.map { |x| heights[x] }
end

def rock_dynamics(chamber, jets, num_rocks)
  jets = jets.cycle
  rock_ids = ROCKS.length.times.cycle

  num_rocks.times do
    chamber = rock_dynamics_single chamber, rock_ids.next, jets
    visualize compute_surface(chamber)
  end

  chamber
end

def rock_dynamics_single(chamber, rock_id, jets)
  rock = init_rock chamber, rock_id
  rock = rock_dynamics_until_collision chamber, rock, jets

  chamber += rock
  minheight = get_bottom chamber
  chamber.select! { |_, y| y >= minheight }

  chamber
end

def get_bottom(chamber)
  # TODO: this is a hack, not real
  heights = compute_chamber_heights chamber
  heights.min - 8
end

def compute_surface(chamber)
  # TODO: complete this
  surface = []

  surface_line = Array.new CHAMBER_WIDTH, false
  reachable_line = Array.new CHAMBER_WIDTH, true
  y = chamber.map { |_, y| y }.max + 1

  until reachable_line.none?
    y -= 1
    reachable_line = update_reachable_line chamber, reachable_line, y

    for x in (0...CHAMBER_WIDTH)
      surface_line[x] = !reachable_line[x]
    end

    for x in (0...CHAMBER_WIDTH)
      surface << [x, y] if surface_line[x]
    end
  end

  surface
end

def update_reachable_line(chamber, reachable_line, y)
  new_reachable_line = reachable_line.dup

  for x in (0...CHAMBER_WIDTH)
    new_reachable_line[x] &= !chamber.include? [x, y]
  end

  for x in (0...CHAMBER_WIDTH)
    new_reachable_line[x] = ...
  end

  for x in (0...CHAMBER_WIDTH)
    new_reachable_line[x] &= !chamber.include? [x, y]
  end

    # if reachable_line[x]
    #   new_reachable_line[x] = true
    #   next
    # end

    # new_reachable_line[x] = (x > 0 && reachable_line[x - 1] && !chamber.include?([x - 1, y])) || \
    #                         (x < CHAMBER_WIDTH - 1 && reachable_line[x + 1] && !chamber.include?([x + 1, y]))
  # end

  new_reachable_line
end

def visualize(chamber)
  ymin, ymax = chamber.map { |_, y| y }.minmax
  xmin = 0
  xmax = CHAMBER_WIDTH - 1

  matrix = Array.new(ymax + 1 - ymin) { ' ' * CHAMBER_WIDTH }
  for x, y in chamber
    matrix[ymax - y + ymin][x] = '#'
  end

  puts '-------'
  puts matrix
end

def rock_dynamics_until_collision(chamber, rock, jets)
  rock, collision = rock_step chamber, rock, jets.next until collision
  rock
end

def collision?(chamber, rock)
  !rock.all? { |x, _| x.between?(0, CHAMBER_WIDTH - 1) } || !(chamber & rock).empty?
end

def rock_step_jet(chamber, rock, jet)
  rock_candidate = move_rock rock, jet
  rock = rock_candidate unless collision? chamber, rock_candidate
  rock
end

def rock_step_fall(chamber, rock)
  rock_candidate = move_rock rock, :v
  collision = collision? chamber, rock_candidate
  rock = rock_candidate unless collision
  [rock, collision]
end

def rock_step(chamber, rock, jet)
  rock = rock_step_jet chamber, rock, jet
  rock_step_fall chamber, rock
end

def move_rock(rock, direction)
  case direction
  when :< then rock.map { |x, y| [x - 1, y] }
  when :> then rock.map { |x, y| [x + 1, y] }
  when :v then rock.map { |x, y| [x, y - 1] }
  end
end

def part1(io)
  jets = parse_data io
  chamber = init_chamber
  chamber = rock_dynamics chamber, jets, 2022
  chamber.map { |_, y| y }.max
end

def part2(io)
  jets = parse_data io
  chamber = init_chamber
  chamber = rock_dynamics chamber, jets, 1_000_000_000_000
  chamber.map { |_, y| y }.max
end

example = '>>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>'
Test.example StringIO.open(example) { |io| part1 io }, 3068
# Test.example StringIO.open(example) { |io| part2 io }, 1_514_285_714_288

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 3067
# Test.solution File.open(input) { |io| part2 io }, nil
