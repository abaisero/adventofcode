#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_io_line(line)
  id = line.match(/Blueprint (\d+):/) { |match| match[1].to_i }

  blueprint = {}
  line.scan(/Each ([a-z]+) robot costs (\d+) ([a-z]+)\./) do |robot, cost, material|
    blueprint[robot.to_sym] = { material.to_sym => cost.to_i }
  end
  line.scan(/Each ([a-z]+) robot costs (\d+) ([a-z]+) and (\d+) ([a-z]+)\./) do |robot, cost1, material1, cost2, material2|
    blueprint[robot.to_sym] = { material1.to_sym => cost1.to_i, material2.to_sym => cost2.to_i }
  end

  [id, blueprint]
end

def parse_io(io)
  lines = io.readlines chomp: true
  lines.map { |line| parse_io_line line }.to_h
end

def init_state(minutes)
  {
    minutes: minutes,
    build_orders: [],
    build_minutes: [],
    robots: {
      ore: 1,
      clay: 0,
      obsidian: 0,
      geode: 0
    },
    materials: {
      ore: Array.new(minutes + 2) { |i| [i - 1, 0].max },
      clay: Array.new(minutes + 2, 0),
      obsidian: Array.new(minutes + 2, 0),
      geode: Array.new(minutes + 2, 0)
    }
  }
end

def valid_build_order?(state, blueprint, build_order)
  blueprint[build_order[:robot]].all? do |material, required|
    materials = state[:materials][material][build_order[:minute]...]
    materials.all? { |quantity| quantity >= required }
  end
end

def valid_ingredients?(state, ingredients, minute)
  ingredients.all? do |material, required|
    state[:materials][material][minute] >= required
  end
end

def find_build_minute(state, ingredients)
  return nil unless valid_ingredients?(state, ingredients, state[:minutes])

  minute = state[:minutes].downto(3).find do |minute|
    !valid_ingredients?(state, ingredients, minute - 1)
  end

  # now find the next possible minute when a robot was not built already
  minute += 1 while state[:build_minutes].include? minute
  minute < state[:minutes] ? minute : nil
end

def available_build_orders(state, blueprint, build_limits)
  robots = %i[obsidian clay ore]
  build_orders = robots.filter_map do |robot|
    next if state[:robots][robot] >= build_limits[robot]

    minute = find_build_minute state, blueprint[robot]
    { robot: robot, minute: minute } unless minute.nil?
  end
end

def dup_state(state)
  state = state.dup
  state[:build_orders] = state[:build_orders].dup
  state[:build_minutes] = state[:build_minutes].dup
  state[:robots] = state[:robots].dup
  state[:materials] = state[:materials].dup
  state[:materials][:ore] = state[:materials][:ore].dup
  state[:materials][:clay] = state[:materials][:clay].dup
  state[:materials][:obsidian] = state[:materials][:obsidian].dup
  state[:materials][:geode] = state[:materials][:geode].dup

  state
end

def get_num_geodes(state)
  state[:materials][:geode][state[:minutes] + 1]
end

def apply_build_order(state, build_order, blueprint)
  state = dup_state state
  state[:build_orders] << build_order
  state[:build_minutes] << build_order[:minute]
  state[:robots][build_order[:robot]] += 1

  for material, required in blueprint[build_order[:robot]] do
    for minute in build_order[:minute]...state[:materials][material].length
      state[:materials][material][minute] -= required
    end
  end

  material = build_order[:robot]
  for minute in build_order[:minute]...state[:materials][material].length
    state[:materials][material][minute] += minute - build_order[:minute] - 1
  end

  state
end

def build_robots(blueprint, state, robot)
  loop do
    minute = find_build_minute state, blueprint[robot]
    break if minute.nil?

    build_order = { robot: robot, minute: minute }
    state = apply_build_order state, build_order, blueprint
  end
  state
end

def search_max_geodes_state(blueprint, state, build_limits)
  # puts
  # puts state[:build_orders].inspect
  max_state = build_robots blueprint, state, :geode
  max_geodes = get_num_geodes max_state

  for build_order in available_build_orders(state, blueprint, build_limits) do
    next_state = apply_build_order state, build_order, blueprint

    candidate_state = search_max_geodes_state blueprint, next_state, build_limits
    candidate_geodes = get_num_geodes candidate_state

    if candidate_geodes > max_geodes
      max_state = candidate_state
      max_geodes = candidate_geodes
    end
  end

  max_state
end

def simulate(build_orders, blueprint, minutes)
  build_orders.sort_by! { |build_order| build_order[:minute] }

  robots = { ore: 1, clay: 0, obsidian: 0, geode: 0 }
  materials = { ore: 0, clay: 0, obsidian: 0, geode: 0 }

  for robot, ingredients in blueprint
    puts "#{robot}: #{ingredients}"
  end

  for minute in 1..minutes
    puts
    puts "== Minute #{minute} =="
    puts "- materials: #{materials.inspect}"
    puts "- robots: #{robots.inspect}"

    build_orders_now = build_orders.select { |build_order| build_order[:minute] == minute }
    for build_order in build_orders_now
      robot = build_order[:robot]
      print 'Spend '
      for material, required in blueprint[robot]
        print "#{required} #{material} "
        materials[material] -= required
      end
      puts "to start building a #{robot}-collecting robot."
    end

    for material in %i[ore clay obsidian geode]
      materials[material] += robots[material]
      if materials[material] > 0
        puts "#{robots[material]} #{material}-collecting robots collect #{robots[material]} #{material}; you now have #{materials[material]} #{material}"
      end
    end

    for build_order in build_orders_now
      robots[build_order[:robot]] += 1
      puts "The new #{robot}-collecting robot is ready; you now have #{robots[build_order[:robot]]} of them."
    end

    puts "- materials: #{materials.inspect}"
    puts "- robots: #{robots.inspect}"

  end
end

def find_max_geodes(blueprint, minutes)
  state = init_state minutes
  build_limits = {
    ore: [blueprint[:clay][:ore], blueprint[:obsidian][:ore], blueprint[:geode][:ore]].max,
    clay: blueprint[:obsidian][:clay],
    obsidian: blueprint[:geode][:obsidian]
  }
  max_geodes_state = search_max_geodes_state blueprint, state, build_limits
  # simulate max_geodes_state[:build_orders], blueprint, minutes
  get_num_geodes max_geodes_state
end

def part1(io)
  blueprints = parse_io io
  max_geodes = blueprints.transform_values { |blueprint| find_max_geodes blueprint, 24 }
  max_geodes.map { |id, geodes| id * geodes }.sum
end

def part2(io)
  blueprints = parse_io io
  blueprints = blueprints.take 3
  max_geodes = blueprints.transform_values { |blueprint| find_max_geodes blueprint, 32 }
  max_geodes.values.reduce :*
end

example = <<~EOF
  Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
  Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.
EOF
Test.example StringIO.open(example) { |io| part1 io }, 33
Test.example StringIO.open(example) { |io| part2 io }, 56 * 62

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 994
Test.solution File.open(input) { |io| part2 io }, 15_960
