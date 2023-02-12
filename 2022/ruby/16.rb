#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'
require 'stringio'
require_relative 'test'

LINE_REGEX = /^Valve (?<valve>[A-Z]+) has flow rate=(?<flow_rate>\d+); tunnels? leads? to valves? (?<connections>[A-Z, ]+)$/

def parse_io_line(line)
  line.match(LINE_REGEX) do |match|
    valve = match[:valve].to_sym
    flow_rate = match[:flow_rate].to_i
    connections = match[:connections].split(', ').map(&:to_sym)
    [valve, { flow_rate: flow_rate, connections: connections }]
  end
end

def parse_io(io)
  lines = io.readlines chomp: true
  lines.map { |line| parse_io_line line }.to_h
end

def init_paths(report)
  paths = Hash.new Float::INFINITY

  report.each do |valve, valve_data|
    paths[[valve, valve]] = 0

    valve_data[:connections].each do |connection|
      paths[[valve, connection]] = 1
    end
  end

  paths
end

def update_paths(paths, valves)
  paths = valves.product(valves).map do |from, to|
    key = [from, to]
    value = valves.map { |mid| paths[[from, mid]] + paths[[mid, to]] }.min
    [key, value]
  end.to_h
end

def compute_paths(report)
  old_paths = nil
  paths = init_paths report

  until paths == old_paths
    old_paths = paths
    paths = update_paths paths, report.keys
  end

  paths
end

def compute_times(report)
  paths = compute_paths report
  paths.transform_values { |time| time + 1 }
end

def init_state(report, num_agents, minutes)
  valves = report.keys
  valves = valves.reject { |valve| report[valve][:flow_rate].zero? }
  valves = valves.sort_by { |valve| report[valve][:flow_rate] }.reverse

  {
    agents: num_agents.times.map { { valve: :AA, minutes: 0 } },
    minutes: minutes,
    pressure: 0,
    valves: valves
  }
end

def copy_state(state)
  next_state = state.dup
  next_state[:agents] = next_state[:agents].map(&:dup)
  next_state
end

def update_minutes(state)
  return if state[:agents].empty?

  min_minutes = state[:agents].map { |agent| agent[:minutes] }.min
  state[:agents].each do |agent|
    agent[:minutes] -= min_minutes
  end

  state[:minutes] -= min_minutes
end

def update_pressure(report, state)
  done_agents = state[:agents].select { |agent| agent[:minutes].zero? }
  done_flow_rate = done_agents.map do |agent|
    valve = agent[:valve]
    report[valve][:flow_rate]
  end.sum
  state[:pressure] += state[:minutes] * done_flow_rate
end

def valid_next_valves?(valves)
  valves_counts = valves.group_by(&:itself).transform_values(&:length)
  valves_counts.reject { |key, _| key == :DONE }.all? { |_, value| value == 1 }
end

def product(array, n)
  array.product(*(n - 1).times.map { array })
end

def compute_next_state(times, state, agent_ids, next_valves)
  next_state = copy_state state
  agent_ids.zip(next_valves).each do |agent_id, next_valve|
    agent = next_state[:agents][agent_id]
    agent[:minutes] = times[[agent[:valve], next_valve]]
    agent[:valve] = next_valve
  end

  next_state[:agents].delete_if { |agent| agent[:valve] == :DONE }
  next_state[:valves] -= next_valves

  next_state
end

def next_states(report, times, state)
  candidates = state[:valves] + [:DONE]
  num_agents = state[:agents].length
  active_agent_ids = num_agents.times.select { |i| state[:agents][i][:minutes].zero? }

  product(candidates, active_agent_ids.length).filter_map do |next_valves|
    next unless valid_next_valves?(next_valves)

    next_state = compute_next_state times, state, active_agent_ids, next_valves
    next next_state if next_state[:agents].empty?

    update_minutes next_state
    next if next_state[:minutes].negative?

    update_pressure report, next_state

    next_state
  end
end

def pressure_heuristic(report, times, state)
  return 0 if state[:agents].empty?

  h = 0

  state[:agents].each do |agent|
    valve = agent[:valve]
    flow = report[valve][:flow_rate]
    minutes = state[:minutes] - agent[:minutes]

    next if minutes.negative?

    h += minutes * flow
  end

  min_times = state[:valves].map do |valve|
    key = valve
    value = state[:agents].map do |agent|
      agent[:minutes] + times[[agent[:valve], valve]]
    end.min
    [key, value]
  end.to_h

  state[:valves].each do |valve|
    flow = report[valve][:flow_rate]
    minutes = state[:minutes] - min_times[valve]

    next if minutes.negative?

    h += minutes * flow
  end

  h
end

def pressure_upper_bound(report, times, state)
  state[:pressure] + pressure_heuristic(report, times, state)
end

def find_max_pressure(report, times, state, max_pressure = 0)
  max_pressure = [max_pressure, state[:pressure]].max

  pressure_ub = pressure_upper_bound report, times, state
  return max_pressure if state[:agents].empty? || pressure_ub < max_pressure

  next_states(report, times, state).each do |next_state|
    max_pressure_candidate = find_max_pressure report, times, next_state, max_pressure
    max_pressure = [max_pressure, max_pressure_candidate].max
  end

  max_pressure
end

def part1(io)
  report = parse_io io
  times = compute_times report
  state = init_state report, 1, 30
  find_max_pressure report, times, state
end

def part2(io)
  report = parse_io io
  times = compute_times report
  state = init_state report, 2, 26
  find_max_pressure report, times, state
end

example = <<~EOF
  Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
  Valve BB has flow rate=13; tunnels lead to valves CC, AA
  Valve CC has flow rate=2; tunnels lead to valves DD, BB
  Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
  Valve EE has flow rate=3; tunnels lead to valves FF, DD
  Valve FF has flow rate=0; tunnels lead to valves EE, GG
  Valve GG has flow rate=0; tunnels lead to valves FF, HH
  Valve HH has flow rate=22; tunnel leads to valve GG
  Valve II has flow rate=0; tunnels lead to valves AA, JJ
  Valve JJ has flow rate=21; tunnel leads to valve II
EOF
Test.example StringIO.open(example) { |io| part1 io }, 1651
Test.example StringIO.open(example) { |io| part2 io }, 1707

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 1915
Test.solution File.open(input) { |io| part2 io }, 2772
