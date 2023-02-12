#!/usr/bin/env ruby
# frozen_string_literal: true

require 'matrix'
require 'stringio'
require_relative 'test'

def parse_data(io)
  scanners = []
  io.each do |line|
    case line
    when /^--- scanner \d+ ---$/ then scanners << []
    when /^-?\d+(,-?\d+)*$/ then scanners.last << line.split(',').map(&:to_i)
    end
  end
  scanners
end

def distance(beacon1, beacon2)
  # beacon1.zip(beacon2).map { |x, y| (x - y).abs }
  beacon1.zip(beacon2).map { |x, y| (x - y).abs }.sum
end

def print_matrix(matrix)
  puts matrix.map(&:inspect)
end

COSINES = [1, 0, -1, 0].freeze
SINES = [0, 1, 0, -1].freeze
ROTATIONS_X = COSINES.zip(SINES).map { |c, s| Matrix[[1, 0, 0], [0, c, -s], [0, s, c]] }
ROTATIONS_Y = COSINES.zip(SINES).map { |c, s| Matrix[[c, 0, s], [0, 1, 0], [-s, 0, c]] }
ROTATIONS_Z = COSINES.zip(SINES).map { |c, s| Matrix[[c, -s, 0], [s, c, 0], [0, 0, 1]] }
ROTATIONS = ROTATIONS_X.product(ROTATIONS_Y, ROTATIONS_Z).map { |rx, ry, rz| rx * ry * rz }.uniq

def canonical(scanner)
  ones = Matrix.build(scanner.length, 1) { 1 }
  Matrix.hstack Matrix.rows(scanner), ones
end

def decanonical(canonical)
  scanner = canonical * Matrix[[1, 0, 0], [0, 1, 0], [0, 0, 1], [0, 0, 0]]
  scanner.to_a
end

def make_transformation(rotation, translation = nil)
  translation = Vector[0, 0, 0] if translation.nil?
  Matrix.vstack Matrix.hstack(rotation, translation), Vector[0, 0, 0, 1].covector
end

def num_shared(scanner1, scanner2)
  (scanner1 & scanner2).length
end

def find_transformation(scanner1, scanner2)
  canonical2 = canonical scanner2

  ROTATIONS.product(scanner1, scanner2).find do |rotation, beacon1, beacon2|
    translation = Vector.elements(beacon1) - rotation * Vector.elements(beacon2)
    transformation = make_transformation rotation, translation

    num = num_shared scanner1, decanonical(canonical2 * transformation.transpose)
    raise if num.zero?

    return num if num >= 12
    # transformation if num >= 12
  end
end

def part1(io)
  scanners = parse_data io
  transformation = find_transformation scanners[0], scanners[1]

  # p scanners.map { |x| scanners.map { |y| p !find_transformation(x, y).nil? } }
  p scanners.map { |x| scanners.map { |y| p find_transformation(x, y) } }
end

def part2(io)
  scanners = parse_data io
  pp scanners
end

example = <<~EOF
  --- scanner 0 ---
  404,-588,-901
  528,-643,409
  -838,591,734
  390,-675,-793
  -537,-823,-458
  -485,-357,347
  -345,-311,381
  -661,-816,-575
  -876,649,763
  -618,-824,-621
  553,345,-567
  474,580,667
  -447,-329,318
  -584,868,-557
  544,-627,-890
  564,392,-477
  455,729,728
  -892,524,684
  -689,845,-530
  423,-701,434
  7,-33,-71
  630,319,-379
  443,580,662
  -789,900,-551
  459,-707,401

  --- scanner 1 ---
  686,422,578
  605,423,415
  515,917,-361
  -336,658,858
  95,138,22
  -476,619,847
  -340,-569,-846
  567,-361,727
  -460,603,-452
  669,-402,600
  729,430,532
  -500,-761,534
  -322,571,750
  -466,-666,-811
  -429,-592,574
  -355,545,-477
  703,-491,-529
  -328,-685,520
  413,935,-424
  -391,539,-444
  586,-435,557
  -364,-763,-893
  807,-499,-711
  755,-354,-619
  553,889,-390

  --- scanner 2 ---
  649,640,665
  682,-795,504
  -784,533,-524
  -644,584,-595
  -588,-843,648
  -30,6,44
  -674,560,763
  500,723,-460
  609,671,-379
  -555,-800,653
  -675,-892,-343
  697,-426,-610
  578,704,681
  493,664,-388
  -671,-858,530
  -667,343,800
  571,-461,-707
  -138,-166,112
  -889,563,-600
  646,-828,498
  640,759,510
  -630,509,768
  -681,-892,-333
  673,-379,-804
  -742,-814,-386
  577,-820,562

  --- scanner 3 ---
  -589,542,597
  605,-692,669
  -500,565,-823
  -660,373,557
  -458,-679,-417
  -488,449,543
  -626,468,-788
  338,-750,-386
  528,-832,-391
  562,-778,733
  -938,-730,414
  543,643,-506
  -524,371,-870
  407,773,750
  -104,29,83
  378,-903,-323
  -778,-728,485
  426,699,580
  -438,-605,-362
  -469,-447,-387
  509,732,623
  647,635,-688
  -868,-804,481
  614,-800,639
  595,780,-596

  --- scanner 4 ---
  727,592,562
  -293,-554,779
  441,611,-461
  -714,465,-776
  -743,427,-804
  -660,-479,-426
  832,-632,460
  927,-485,-438
  408,393,-506
  466,436,-512
  110,16,151
  -258,-428,682
  -393,719,612
  -211,-452,876
  808,-476,-593
  -575,615,604
  -485,667,467
  -680,325,-822
  -627,-443,-432
  872,-547,-609
  833,512,582
  807,604,487
  839,-516,451
  891,-625,532
  -652,-548,-490
  30,-46,-14
EOF
test_example StringIO.open(example) { |io| part1 io }, 79
# test_example StringIO.open(example) { |io| part2 io }, nil

input = "#{File.basename(__FILE__, '.rb')}.txt"
# puts File.open(input) { |io| part1 io }
# puts File.open(input) { |io| part2 io }
