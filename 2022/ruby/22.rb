#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'matrixtools'
require_relative 'test'

# key represents a path on the flat surface
# value represents the exit and entry direction between the path endpoints
PATH_CONNECTION = {
  %i[> v] => %i[v >],
  %i[> ^] => %i[^ >],
  %i[v >] => %i[> v],
  %i[v <] => %i[< v],
  %i[< v] => %i[v <],
  %i[< ^] => %i[^ <],
  %i[^ >] => %i[> ^],
  %i[^ <] => %i[< ^],
  %i[> > >] => %i[< <],
  %i[> > v] => %i[v ^],
  %i[> > ^] => %i[^ v],
  %i[> v v] => %i[< >],
  %i[> ^ ^] => %i[< >],
  %i[v > >] => %i[^ v],
  %i[v v >] => %i[> <],
  %i[v v v] => %i[^ ^],
  %i[v v <] => %i[< >],
  %i[v < <] => %i[^ v],
  %i[< v v] => %i[> <],
  %i[< < v] => %i[v ^],
  %i[< < <] => %i[> >],
  %i[< < ^] => %i[^ v],
  %i[< ^ ^] => %i[> <],
  %i[^ > >] => %i[v ^],
  %i[^ < <] => %i[v ^],
  %i[^ ^ >] => %i[> <],
  %i[^ ^ <] => %i[< >],
  %i[^ ^ ^] => %i[v v],
  %i[> > > v] => %i[v <],
  %i[> > > ^] => %i[^ <],
  %i[> > v >] => %i[< ^],
  %i[> > ^ >] => %i[< v],
  %i[> v > >] => %i[^ <],
  %i[> v > v] => %i[< ^],
  %i[> v v v] => %i[^ >],
  %i[> ^ > >] => %i[v <],
  %i[> ^ > ^] => %i[< v],
  %i[> ^ ^ ^] => %i[v >],
  %i[v > > >] => %i[< v],
  %i[v > v >] => %i[^ <],
  %i[v > v v] => %i[< ^],
  %i[v v > v] => %i[^ <],
  %i[v v v >] => %i[> ^],
  %i[v v v <] => %i[< ^],
  %i[v v < v] => %i[^ >],
  %i[v < v v] => %i[> ^],
  %i[v < v <] => %i[^ >],
  %i[v < < <] => %i[> v],
  %i[< v v v] => %i[^ <],
  %i[< v < v] => %i[> ^],
  %i[< v < <] => %i[^ >],
  %i[< < v <] => %i[> ^],
  %i[< < < v] => %i[v >],
  %i[< < < ^] => %i[^ >],
  %i[< < ^ <] => %i[> v],
  %i[< ^ < <] => %i[v >],
  %i[< ^ < ^] => %i[> v],
  %i[< ^ ^ ^] => %i[v <],
  %i[^ > > >] => %i[< ^],
  %i[^ > ^ >] => %i[v <],
  %i[^ > ^ ^] => %i[< v],
  %i[^ < < <] => %i[> ^],
  %i[^ < ^ <] => %i[v >],
  %i[^ < ^ ^] => %i[> v],
  %i[^ ^ > ^] => %i[v <],
  %i[^ ^ < ^] => %i[v >],
  %i[^ ^ ^ >] => %i[> v],
  %i[^ ^ ^ <] => %i[< v],
  %i[> v > > v] => %i[< <],
  %i[> v > v >] => %i[^ ^],
  %i[> v v > v] => %i[^ ^],
  %i[> ^ > > ^] => %i[< <],
  %i[> ^ > ^ >] => %i[v v],
  %i[> ^ ^ > ^] => %i[v v],
  %i[v > > v >] => %i[< <],
  %i[v > v > v] => %i[< <],
  %i[v > v v >] => %i[^ ^],
  %i[v < v v <] => %i[^ ^],
  %i[v < v < v] => %i[> >],
  %i[v < < v <] => %i[> >],
  %i[< v v < v] => %i[^ ^],
  %i[< v < v <] => %i[^ ^],
  %i[< v < < v] => %i[> >],
  %i[< ^ < < ^] => %i[> >],
  %i[< ^ < ^ <] => %i[v v],
  %i[< ^ ^ < ^] => %i[v v],
  %i[^ > > ^ >] => %i[< <],
  %i[^ > ^ > ^] => %i[< <],
  %i[^ > ^ ^ >] => %i[v v],
  %i[^ < < ^ <] => %i[> >],
  %i[^ < ^ < ^] => %i[> >],
  %i[^ < ^ ^ <] => %i[v v]
}.freeze

ORIENTATIONS = %i[> v < ^].freeze

ORIENTATION_DELTA = {
  :> => [0, 1],
  :v => [1, 0],
  :< => [0, -1],
  :^ => [-1, 0]
}.freeze

def fill_spaces(map)
  max_width = map.map(&:length).max
  map.map { |row| row + [' '] * (max_width - row.length) }
end

def parse_io(io)
  lines = io.readlines chomp: true

  map = lines[...-2].map(&:chars)
  map = fill_spaces map

  path_steps = lines.last.scan(/\d+/).map(&:to_i)
  path_turns = lines.last.scan(/[LR]/).map(&:to_sym)
  path = path_steps.zip(path_turns).flatten.compact

  [map, path]
end

def decompose_position(position, size)
  i, j = position
  hyper_i, hypo_i = i.divmod size
  hyper_j, hypo_j = j.divmod size
  hyper_position = [hyper_i, hyper_j]
  hypo_position = [hypo_i, hypo_j]
  [hyper_position, hypo_position]
end

def compose_position(hyper_position, hypo_position, size)
  hyper_i, hyper_j = hyper_position
  hypo_i, hypo_j = hypo_position
  i = size * hyper_i + hypo_i
  j = size * hyper_j + hypo_j
  [i, j]
end

def flat_step(state)
  state = state.dup

  delta = ORIENTATION_DELTA[state[:orientation]]
  state[:position] = add_positions state[:position], delta

  state
end

def step(state, info, connections)
  candidate = connections[state]
  candidate = flat_step state if candidate.nil?

  next_tile = info[:map].dig(*candidate[:position])
  next_tile == '.' ? candidate : state
end

def walk(state, num_steps, info, connections)
  num_steps.times do
    next_state = step state, info, connections
    break if state == next_state

    state = next_state
  end
  state
end

TURN_ORIENTATIONS = {
  %i[> R] => :v,
  %i[v R] => :<,
  %i[< R] => :^,
  %i[^ R] => :>,
  %i[> L] => :^,
  %i[v L] => :>,
  %i[< L] => :v,
  %i[^ L] => :<
}.freeze

def turn(state, turn_direction)
  state = state.dup
  state[:orientation] = TURN_ORIENTATIONS[[state[:orientation], turn_direction]]
  state
end

def init_state(info)
  init_j = info[:map].first.index('.')
  {
    position: [0, init_j],
    orientation: :>
  }
end

def execute_path_step(state, path_step, info, connections)
  case path_step
  when Integer then walk state, path_step, info, connections
  when Symbol then turn state, path_step
  end
end

def execute_path(state, path, info, connections)
  path.each do |path_step|
    state = execute_path_step state, path_step, info, connections
  end
  state
end

ORIENTATION_VALUES = { :> => 0, :v => 1, :< => 2, :^ => 3 }

def final_password(state)
  i, j = state[:position]
  position_value = (i + 1) * 1000 + (j + 1) * 4
  orientation_value = ORIENTATION_VALUES[state[:orientation]]
  position_value + orientation_value
end

def part1(io)
  map, path = parse_io io
  info = compile_info map
  connections = compile_connections1 info
  state = init_state info
  state = execute_path state, path, info, connections
  final_password state
end

def compute_size(map)
  area = map.flatten.join.chars.count { |x| x != ' ' }
  Math.sqrt(area / 6).to_i
end

def make_map(shape)
  height, width = shape
  Array.new(height) { [nil] * width }
end

def make_hyper_map(map, shape, size)
  hyper_shape = shape.map { |x| x / size }
  hyper_map = make_map hyper_shape

  indices = indices(hyper_shape).each
  (1..6).each do |k|
    i, j = indices.next
    i, j = indices.next until map[size * i][size * j] != ' '
    hyper_map[i][j] = k
  end

  [hyper_map, hyper_shape]
end

def add_deltas(deltas)
  i = deltas.map(&:first).sum
  j = deltas.map(&:last).sum
  [i, j]
end

def path_position(position, path)
  i, j = position
  di, dj = add_deltas(path.map(&ORIENTATION_DELTA))
  [i + di, j + dj]
end

def init_path(position)
  {
    start: position,
    orientations: [],
    end: position
  }
end

def add_positions(position1, position2)
  position1.zip(position2).map { |x1, x2| x1 + x2 }
end

def valid_path?(position, path, info)
  return false if info[:hyper_map].dig(*position).nil?
  return true if path.empty?

  next_position = add_positions position, ORIENTATION_DELTA[path.first]
  return false unless MatrixTools.in_shape? next_position, info[:hyper_shape]

  next_path = path[1...]
  valid_path? next_position, next_path, info
end

def find_exit_hypo_k(hypo_position, orientation, size)
  i, j = hypo_position
  case orientation
  when :> then i
  when :v then size - j - 1
  when :< then size - i - 1
  when :^ then j
  end
end

def compose_entry_hypo_position(orientation, k, size)
  case orientation
  when :> then [k, 0]
  when :v then [0, size - k - 1]
  when :< then [size - k - 1, size - 1]
  when :^ then [size - 1, k]
  end
end

def next_hypo_position(hypo_position, exit_orientation, entry_orientation, size)
  k = find_exit_hypo_k hypo_position, exit_orientation, size
  compose_entry_hypo_position entry_orientation, k, size
end

def find_connecting_state2(state, info)
  PATH_CONNECTION.each do |path, connection_orientations|
    exit_orientation, entry_orientation = connection_orientations
    next unless exit_orientation == state[:orientation]

    hyper_position, hypo_position = decompose_position state[:position], info[:size]
    next unless valid_path? hyper_position, path, info

    next_hyper_position = path_position hyper_position, path
    next_hypo_position = next_hypo_position hypo_position, exit_orientation, entry_orientation, info[:size]

    next_position = compose_position next_hyper_position, next_hypo_position, info[:size]
    next_orientation = entry_orientation

    return {
      position: next_position,
      orientation: next_orientation
    }
  end
end

def normalize_position(position, shape)
  position.zip(shape).map { |i, s| i % s }
end

def find_connecting_state1(state, info)
  state = state.dup

  state = flat_step state
  state[:position] = normalize_position state[:position], info[:shape]

  until info[:map].dig(*state[:position]) != ' '
    state = flat_step state
    state[:position] = normalize_position state[:position], info[:shape]
  end

  state
end

def compile_connections1(info)
  missing_connections(info).map do |state|
    next_state = find_connecting_state1 state, info
    [state, next_state]
  end.to_h
end

def indices(shape)
  height, width = shape
  is = (0...height).to_a
  js = (0...width).to_a
  is.product(js)
end

def missing_connections(info)
  indices(info[:shape]).map do |position|
    tile = info[:map].dig(*position)
    next unless tile == '.'

    ORIENTATIONS.map do |orientation|
      state = { position: position, orientation: orientation }
      next_state = flat_step state

      in_shape = MatrixTools.in_shape? next_state[:position], info[:shape]
      next_tile = info[:map].dig(*next_state[:position])

      missing_connection = !in_shape || next_tile == ' '
      state if missing_connection
    end
  end.flatten.compact
end

def compile_info(map)
  shape = MatrixTools.shape map
  size = compute_size map
  hyper_map, hyper_shape = make_hyper_map map, shape, size
  {
    map: map,
    shape: shape,
    size: size,
    hyper_map: hyper_map,
    hyper_shape: hyper_shape
  }
end

def compile_connections2(info)
  missing_connections(info).map do |state|
    next_state = find_connecting_state2 state, info
    [state, next_state]
  end.to_h
end

def part2(io)
  map, path = parse_io io
  info = compile_info map
  connections = compile_connections2 info
  state = init_state info
  state = execute_path state, path, info, connections
  final_password state
end

example = <<~EOF
          ...#
          .#..
          #...
          ....
  ...#.......#
  ........#...
  ..#....#....
  ..........#.
          ...#....
          .....#..
          .#......
          ......#.

  10R5L5R10L4R5L5
EOF
Test.example StringIO.open(example) { |io| part1 io }, 6032
Test.example StringIO.open(example) { |io| part2 io }, 5031

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 197_160
Test.solution File.open(input) { |io| part2 io }, 145_065
