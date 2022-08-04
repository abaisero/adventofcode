#!/usr/bin/env ruby
# frozen_string_literal: true

def read_data(filename)
  File.foreach(filename).map(&:strip)
end

# receives a bitstring, and provides a take to parse it bit-by-bit
class BitReader
  def initialize(bits)
    @bits = bits
    @i = 0
  end

  def take(nbits)
    raise 'must request at least one bit' unless nbits.positive?
    raise 'not enough bits' if nbits > @bits.length - @i

    @i += nbits
    @bits[@i - nbits...@i]
  end

  def empty?
    @i == @bits.length
  end

  def to_s
    "#{@bits}\n" + '^'.rjust(@i + 1)
  end
end

def hex_to_bits(char)
  char.hex.to_s(2).rjust(4, '0')
end

def hexstring_to_bitstring(hexstring)
  hexstring.each_char.map { |char| hex_to_bits char }.join
end

def make_literal_value(bitreader)
  valuebits = []
  loop do
    controlbit = bitreader.take 1
    chunkbits = bitreader.take 4
    valuebits << chunkbits
    break if controlbit == '0'
  end

  valuebits.join.to_i(2)
end

def make_subpackets_type0(bitreader)
  length = bitreader.take(15).to_i(2)
  bitstring = bitreader.take length
  subreader = BitReader.new bitstring

  subpackets = []
  subpackets << make_packet(subreader) until subreader.empty?
  subpackets
end

def make_subpackets_type1(bitreader)
  num_subpackets = bitreader.take(11).to_i(2)
  num_subpackets.times.map { make_packet bitreader }
end

def make_subpackets(bitreader)
  length_type_id = bitreader.take 1
  case length_type_id
  when '0' then make_subpackets_type0 bitreader
  when '1' then make_subpackets_type1 bitreader
  end
end

def make_packet(bitreader)
  version = bitreader.take(3).to_i(2)
  type_id = bitreader.take(3).to_i(2)
  content = type_id == 4 ? make_literal_value(bitreader) : make_subpackets(bitreader)
  { version: version, type_id: type_id, content: content }
end

def hexstring_to_packet(hexstring)
  bitstring = hexstring_to_bitstring hexstring
  bitreader = BitReader.new bitstring
  make_packet bitreader
end

def compute_version(packet)
  return packet[:version] if packet[:type_id] == 4

  subversions = packet[:content].map { |subpacket| compute_version subpacket }
  packet[:version] + subversions.sum
end

def part1(filename)
  hexstrings = read_data filename
  packets = hexstrings.map { |hexstring| hexstring_to_packet(hexstring) }
  packets.map { |packet| compute_version packet }
end

def compute_value(packet)
  return packet[:content] if packet[:type_id] == 4

  subvalues = packet[:content].map { |subpacket| compute_value subpacket }
  case packet[:type_id]
  when 0 then subvalues.sum
  when 1 then subvalues.reduce :*
  when 2 then subvalues.min
  when 3 then subvalues.max
  when 5 then subvalues[0] > subvalues[1] ? 1 : 0
  when 6 then subvalues[0] < subvalues[1] ? 1 : 0
  when 7 then subvalues[0] == subvalues[1] ? 1 : 0
  end
end

def part2(filename)
  hexstrings = read_data filename
  packets = hexstrings.map { |hexstring| hexstring_to_packet hexstring }
  packets.map { |packet| compute_value packet }
end

p part1 '16.example.txt'
p part1 '16.txt'
p part2 '16.example.txt'
p part2 '16.txt'
