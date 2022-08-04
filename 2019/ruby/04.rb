#!/usr/bin/env ruby
# frozen_string_literal: true

def read_data(filename)
  File.read(filename).strip.split('-').map(&:chars)
end

def check_password_range(password, range)
  min, max = range

  password = password.join.to_i
  min = min.join.to_i
  max = max.join.to_i
  min <= password && password <= max
end

def check_password_pair1(password)
  password.each_cons(2).any? { |x, y| x == y }
end

def check_password_increasing(password)
  password.each_cons(2).all? { |x, y| x <= y }
end

def check_password1(password, range = nil)
  (range.nil? || check_password_range(password, range)) &&
    check_password_pair1(password) &&
    check_password_increasing(password)
end

def generate_passwords_inner(range, password)
  return [password] if password.length == 6

  password.last.upto('9').flat_map { |c| generate_passwords_inner range, password + [c] }
end

def generate_passwords(range)
  min, = range
  passwords = min.first.upto('9').flat_map { |c| generate_passwords_inner range, [c] }
end

raise unless check_password1(%w[1 1 1 1 1 1])
raise if check_password1(%w[2 2 3 4 5 0])
raise if check_password1(%w[1 2 3 7 8 9])

def part1(filename)
  range = read_data filename
  passwords = generate_passwords range
  passwords.select { |password| check_password1 password, range }.count
end

def check_password_pair2(password)
  pairs = password.each_cons(2).select { |x, y| x == y }.flatten.uniq
  counts = password.group_by(&:itself).transform_values(&:length)
  pairs.any? { |p| counts[p] == 2 }
end

def check_password2(password, range = nil)
  (range.nil? || check_password_range(password, range)) &&
    check_password_pair2(password) &&
    check_password_increasing(password)
end

raise unless check_password2(%w[1 1 2 2 3 3])
raise if check_password2(%w[1 2 3 4 4 4])
raise unless check_password2(%w[1 1 1 1 2 2])

def part2(filename)
  range = read_data filename
  passwords = generate_passwords range
  passwords.select { |password| check_password2 password, range }.count
end

p part1 '04.txt'
p part2 '04.txt'
