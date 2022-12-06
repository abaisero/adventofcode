#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'
require_relative 'utils'

def parse_data(io)
  text = io.read.chomp
  match = text.match(/^target area: x=(?<x0>-?\d+)..(?<x1>-?\d+), y=(?<y0>-?\d+)..(?<y1>-?\d+)$/)
  xrange = (match['x0'].to_i)..(match['x1'].to_i)
  yrange = (match['y0'].to_i)..(match['y1'].to_i)
  { xrange: xrange, yrange: yrange }
end

def transition(state)
  {
    x: state[:x] + state[:vx],
    y: state[:y] + state[:vy],
    vx: next_value(state[:vx], 0),
    vy: state[:vy] - 1
  }
end

def in_target?(target, state)
  (target[:xrange].include? state[:x]) && (target[:yrange].include? state[:y])
end

def overshot_target?(target, state)
  (state[:x] > target[:xrange].max) || (state[:y] < target[:yrange].min)
end

def hits_target?(target, state)
  loop do
    return true if in_target? target, state
    return false if overshot_target? target, state

    state = transition state
  end
end

def find_min_vx(target)
  # finds smallest vx such that vx-1 cannot reach target, while vx can
  (1...).find do |n|
    (n**2 - n < 2 * target[:xrange].min) && (n**2 + n >= 2 * target[:xrange].min)
  end
end

def compute_vxrange(target)
  # finds range of possible vx such that state can (potentially) reach target
  min_vx = find_min_vx target
  max_vx = target[:xrange].max

  min_vx..max_vx
end

def compute_vyrange(target)
  # finds range of possible vy such that state can (potentially) reach target
  min_vx = target[:yrange].min
  # the y-axis trajectory is symmetric above the y=0 axis,
  # so the curve will hit y=0 again with an opposite vy velocity
  max_vx = -target[:yrange].min
  (min_vx...max_vx)
end

def make_starting_state(vx, vy)
  { x: 0, y: 0, vx: vx, vy: vy }
end

def compute_max_y(state)
  state[:vy].positive? ? state[:vy] * (state[:vy] + 1) / 2 : 0
end

def find_style_shot(target)
  vxrange = compute_vxrange target
  vyrange = compute_vyrange target
  vs = vyrange.reverse_each.flat_map { |vy| vxrange.map { |vx| [vx, vy] } }
  shots = vs.map { |vx, vy| make_starting_state vx, vy }
  shots.find { |shot| hits_target? target, shot }
end

def part1(io)
  target = parse_data io
  shot = find_style_shot target
  compute_max_y shot
end

def find_shots(target)
  vxrange = compute_vxrange target
  vyrange = compute_vyrange target
  vs = vyrange.flat_map { |vy| vxrange.map { |vx| [vx, vy] } }
  shots = vs.map { |vx, vy| make_starting_state vx, vy }
  shots.select { |shot| hits_target? target, shot }
end

def part2(io)
  target = parse_data io
  shots = find_shots target
  shots.count
end

example = 'target area: x=20..30, y=-10..-5'
test_example StringIO.open(example) { |io| part1 io }, 45
test_example StringIO.open(example) { |io| part2 io }, 112

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
