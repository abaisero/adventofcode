# frozen_string_literal: true

def read_data(filename)
  File.foreach(filename).map { |line| line.strip.split('').map(&:to_i) }
end

def bits_to_int(bits)
  bits.map(&:to_s).join.to_i(2)
end

def compute_gamma_rating(data, bitcounts)
  gammabits = bitcounts.map { |bitcount| 2 * bitcount > data.length ? 1 : 0 }
  bits_to_int(gammabits)
end

def compute_epsilon_rating(data, bitcounts)
  epsilonbits = bitcounts.map { |bitcount| 2 * bitcount >= data.length ? 0 : 1 }
  bits_to_int(epsilonbits)
end

def part1(filename)
  data = read_data filename

  bitcounts = data.transpose.map(&:sum)
  gamma_rating = compute_gamma_rating(data, bitcounts)
  epsilon_rating = compute_epsilon_rating(data, bitcounts)
  gamma_rating * epsilon_rating
end

def compute_rating(bitarrays, select_key, index = 0)
  return bits_to_int bitarrays[0] if bitarrays.one?

  groups = bitarrays.group_by { |bitarray| bitarray[index] }
  bitarrays = if groups.keys.one?
                groups[groups.keys[0]]
              elsif groups[0].length <= groups[1].length
                groups[select_key]
              else
                groups[1 - select_key]
              end

  compute_rating(bitarrays, select_key, index + 1)
end

def compute_oxygen_rating(data)
  compute_rating(data, 1)
end

def compute_co2_rating(data)
  compute_rating(data, 0)
end

def part2(filename)
  data = read_data filename

  oxygen_rating = compute_oxygen_rating data
  co2_rating = compute_co2_rating data
  oxygen_rating * co2_rating
end

p part1 '03.example.txt'
p part1 '03.txt'
p part2 '03.example.txt'
p part2 '03.txt'
