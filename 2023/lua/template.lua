#!/usr/bin/env lua

local utils = require('utils')
local testing = require('testing')

local function get_input_filename()
  return debug.getinfo(1,'S').source:sub(2):match("[^/]*.lua$"):gsub('.lua', '.txt')
end

local function parse_io_line(line)
  return line
end

local function parse_io(file)
  local lines = {}
  for line in file:lines() do
    local d = parse_io_line(line)
    table.insert(lines, d)
  end

  return lines
end

local function part1(file)
  parse_io(file)
end

local function part2(file)
  parse_io(file)
end

local example = [[
]]

local file = utils.make_tmpfile(example)
testing.example(part1(file), nil)
-- testing.example(part2(file), nil)

file = assert(io.open(get_input_filename()))
testing.solution(part1(file), nil)
-- testing.solution(part2(file), nil)
