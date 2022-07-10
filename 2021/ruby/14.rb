# frozen_string_literal: true

PADDING = '.'
def read_data(filename)
  lines = File.foreach(filename).map(&:strip)
  template = "#{PADDING}#{lines.first}#{PADDING}".split('')
  rules = lines[2..].map { |line| [line[0], line[1], line[-1]] }
  [template, rules]
end

def make_paircounts(template, rules)
  letters = (template + rules.flatten).uniq.sort
  paircounts = letters.product(letters).map { |a, b| [[a, b], 0] }.to_h
  template.each_cons(2).each do |a, b|
    paircounts[[a, b]] += 1
  end
  paircounts
end

def run_step(paircounts, rules)
  old_paircounts = paircounts.dup
  rules.each do |a, b, c|
    paircounts[[a, b]] -= old_paircounts[[a, b]]
    paircounts[[a, c]] += old_paircounts[[a, b]]
    paircounts[[c, b]] += old_paircounts[[a, b]]
  end
end

def score(paircounts)
  letters = paircounts.keys.flatten.uniq - [PADDING]
  # only count the times a letter appears at the beginning of a pair
  counts = letters.map { |l| paircounts.select { |k, _| k[0] == l }.values.sum }
  counts.max - counts.min
end

def part1(filename)
  template, rules = read_data filename
  paircounts = make_paircounts(template, rules)
  10.times { run_step(paircounts, rules) }
  score paircounts
end

def part2(filename)
  template, rules = read_data filename
  paircounts = make_paircounts(template, rules)
  40.times { run_step(paircounts, rules) }
  score paircounts
end

p part1 '14.example.txt'
p part1 '14.txt'
p part2 '14.example.txt'
p part2 '14.txt'
