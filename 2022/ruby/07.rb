#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'data_stack'
require_relative 'test'

FOLDER_FORMAT = /^[a-z]+$/
PATH_FORMAT = %r{^/([a-z]+(/[a-z]+)*)?$}

# Path
module Path
  def self.new(string)
    raise 'invalid path' unless string.match? PATH_FORMAT

    { string: string }
  end

  ROOT = Path.new '/'

  def self.depth(path)
    path[:string] == '/' ? 0 : path[:string].count('/')
  end

  def self.child?(path, child_path)
    descendant = Path.descendant? path, child_path
    path_depth = Path.depth path
    child_depth = Path.depth child_path
    descendant && child_depth == path_depth + 1
  end

  def self.descendant?(path, descendant_path)
    descendant_path[:string].include? path[:string]
  end

  def self.child(path, folder)
    raise unless folder.match?(FOLDER_FORMAT)

    folders = path[:string][1...].split('/')
    folders += [folder]
    child_string = folders.join('/')
    child_string = "/#{child_string}"
    Path.new child_string
  end

  def self.parent(path)
    return Path.new('/') if Path.depth(path) < 2

    folders = path[:string].split '/'
    parent_folders = folders[...-1]
    parent_string = parent_folders.join '/'
    Path.new parent_string
  end
end

# FileSystem
# keeps track of path sizes
module FileSystem
  def self.new
    FrozenHash.new Hash.new 0
  end

  def self.get_size(file_system, path)
    file_system[path]
  end

  def self.set_size(file_system, path, size)
    FrozenHash.set file_system, path, size
  end

  def self.paths(file_system)
    file_system.keys
  end

  def self.each(file_system, &block)
    if block_given?
      file_system.each(&block)
    else
      file_system.each
    end
  end
end

module CWD
  def self.new
    Path::ROOT
  end

  def self.change_directory_root
    Path::ROOT
  end

  def self.change_directory_parent(path)
    Path.parent path
  end

  def self.change_directory_folder(path, folder)
    Path.child path, folder
  end

  def self.change_directory(cwd, folder)
    case folder
    when '/' then CWD.change_directory_root
    when '..' then CWD.change_directory_parent cwd
    else CWD.change_directory_folder cwd, folder
    end
  end
end

# FileSystemOperations
module FileSystemOperations
  def self.ancestors(path)
    ancestors = []

    loop do
      ancestors << path
      break if path == Path::ROOT

      path = Path.parent path
    end

    ancestors
  end

  def self.compute_file_system(terminal)
    file_system = FileSystem.new
    cwd = CWD.new
    Terminal.each(terminal) do |command|
      file_system, cwd = execute_command file_system, cwd, command
    end

    file_system
  end

  def self.update_ancestor_paths_sizes(file_system, path, size)
    ancestors = FileSystemOperations.ancestors path
    ancestors.each do |ancestor|
      ancestor_size = FileSystem.get_size file_system, ancestor
      ancestor_size += size
      file_system = FileSystem.set_size file_system, ancestor, ancestor_size
    end
    file_system
  end

  def self.select_paths(file_system, &block)
    FileSystem.each(file_system).select(&block).map { |path, _| path }
  end

  def self.find_path_to_delete(file_system, max_file_system_size)
    total_size = FileSystem.get_size file_system, Path::ROOT
    min_delete_size = total_size - max_file_system_size
    paths = FileSystemOperations.select_paths(file_system) { |_, size| size >= min_delete_size }
    paths.min_by { |path| FileSystem.get_size file_system, path }
  end
end

# Terminal
# a terminal is a sequence of commands
module Terminal
  def self.new
    FrozenArray.new
  end

  def self.each(terminal, &block)
    if block_given?
      terminal.each(&block)
    else
      terminal.each
    end
  end

  def self.add(terminal, command)
    FrozenArray.append terminal, command
  end

  def self.get_last(terminal)
    terminal.last
  end

  def self.remove_last(terminal)
    terminal = terminal.dup
    terminal[...-1]
  end

  def self.pop_last(terminal)
    command = Terminal.get_last terminal
    terminal = Terminal.remove_last terminal
    [terminal, command]
  end
end

# Command
module Command
  def self.new(input)
    outputs = FrozenArray.new
    FrozenHash.new input: input, outputs: outputs
  end

  def self.get_input(command)
    command[:input]
  end

  def self.get_outputs(command)
    command[:outputs]
  end

  def self.get(command, field)
    command[field]
  end

  def self.set(command, field, value)
    FrozenHash.set command, field, value
  end

  def self.add_output_line(command, line)
    outputs = FrozenArray.append command[:outputs], line
    Command.set command, :outputs, outputs
  end
end

def command_line_input?(line)
  line.start_with? '$ '
end

def parse_io_input_line(terminal, line)
  command = Command.new line
  Terminal.add terminal, command
end

def parse_io_output_line(terminal, line)
  terminal, command = Terminal.pop_last terminal
  command = Command.add_output_line command, line
  Terminal.add terminal, command
end

def parse_io_line(terminal, line)
  if command_line_input? line
    parse_io_input_line terminal, line
  else
    parse_io_output_line terminal, line
  end
end

def parse_io_lines(lines)
  terminal = Terminal.new
  lines.each do |line|
    terminal = parse_io_line terminal, line
  end
  terminal
end

def parse_io(io)
  lines = io.readlines chomp: true
  parse_io_lines lines
end

def execute_command(file_system, cwd, command)
  input = Command.get_input command

  input.match(/^\$ cd (\S+)$/) do |match|
    folder = match[1]
    cwd = CWD.change_directory cwd, folder
  end

  outputs = Command.get_outputs command
  outputs.each do |output|
    output.match(/^(\d+) \S+$/) do |match|
      size = match[1].to_i
      file_system = FileSystemOperations.update_ancestor_paths_sizes file_system, cwd, size
    end
  end
  [file_system, cwd]
end

def part1(io)
  terminal = parse_io io
  file_system = FileSystemOperations.compute_file_system terminal
  paths = FileSystemOperations.select_paths(file_system) { |_, size| size <= 100_000 }
  paths.map { |path| FileSystem.get_size file_system, path }.sum
end

MAX_FILE_SYSTEM_SIZE = 40_000_000

def part2(io)
  terminal = parse_io io
  file_system = FileSystemOperations.compute_file_system terminal
  path = FileSystemOperations.find_path_to_delete file_system, MAX_FILE_SYSTEM_SIZE
  FileSystem.get_size file_system, path
end

example = <<~EOF
  $ cd /
  $ ls
  dir a
  14848514 b.txt
  8504156 c.dat
  dir d
  $ cd a
  $ ls
  dir e
  29116 f
  2557 g
  62596 h.lst
  $ cd e
  $ ls
  584 i
  $ cd ..
  $ cd ..
  $ cd d
  $ ls
  4060174 j
  8033020 d.log
  5626152 d.ext
  7214296 k
EOF
Test.example StringIO.open(example) { |io| part1 io }, 95_437
Test.example StringIO.open(example) { |io| part2 io }, 24_933_642

input = "#{File.basename(__FILE__, '.rb')}.txt"
Test.solution File.open(input) { |io| part1 io }, 1_583_951
Test.solution File.open(input) { |io| part2 io }, 214_171
