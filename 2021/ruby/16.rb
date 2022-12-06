#!/usr/bin/env ruby
# frozen_string_literal: true

require 'stringio'
require_relative 'test'

def parse_data(io)
  io.read.chomp
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

def part1(io)
  hexstring = parse_data io
  packet = hexstring_to_packet hexstring
  compute_version packet
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

def part2(io)
  hexstring = parse_data io
  packet = hexstring_to_packet hexstring
  compute_value packet
end

example = 'D2FE28'
test_example StringIO.open(example) { |io| part1 io }, 6
test_example StringIO.open(example) { |io| part2 io }, 2021

example = '38006F45291200'
test_example StringIO.open(example) { |io| part1 io }, 9
test_example StringIO.open(example) { |io| part2 io }, 1

example = 'EE00D40C823060'
test_example StringIO.open(example) { |io| part1 io }, 14
test_example StringIO.open(example) { |io| part2 io }, 3

example = '8A004A801A8002F478'
test_example StringIO.open(example) { |io| part1 io }, 16
test_example StringIO.open(example) { |io| part2 io }, 15

example = '620080001611562C8802118E34'
test_example StringIO.open(example) { |io| part1 io }, 12
test_example StringIO.open(example) { |io| part2 io }, 46

example = 'C0015000016115A2E0802F182340'
test_example StringIO.open(example) { |io| part1 io }, 23
test_example StringIO.open(example) { |io| part2 io }, 46

example = 'A0016C880162017C3686B18A3D4780'
test_example StringIO.open(example) { |io| part1 io }, 31
test_example StringIO.open(example) { |io| part2 io }, 54

example = 'C200B40A82'
test_example StringIO.open(example) { |io| part1 io }, 14
test_example StringIO.open(example) { |io| part2 io }, 3

example = '04005AC33890'
test_example StringIO.open(example) { |io| part1 io }, 8
test_example StringIO.open(example) { |io| part2 io }, 54

example = '880086C3E88112'
test_example StringIO.open(example) { |io| part1 io }, 15
test_example StringIO.open(example) { |io| part2 io }, 7

example = 'CE00C43D881120'
test_example StringIO.open(example) { |io| part1 io }, 11
test_example StringIO.open(example) { |io| part2 io }, 9

example = 'D8005AC2A8F0'
test_example StringIO.open(example) { |io| part1 io }, 13
test_example StringIO.open(example) { |io| part2 io }, 1

example = 'F600BC2D8F'
test_example StringIO.open(example) { |io| part1 io }, 19
test_example StringIO.open(example) { |io| part2 io }, 0

example = '9C005AC2F8F0'
test_example StringIO.open(example) { |io| part1 io }, 16
test_example StringIO.open(example) { |io| part2 io }, 0

example = '9C0141080250320F1802104A08'
test_example StringIO.open(example) { |io| part1 io }, 20
test_example StringIO.open(example) { |io| part2 io }, 1

input = "#{File.basename(__FILE__, '.rb')}.txt"
puts File.open(input) { |io| part1 io }
puts File.open(input) { |io| part2 io }
