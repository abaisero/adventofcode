# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'utils'

describe 'make_matrix' do
  matrix = make_matrix(2, 3)

  it 'has 2 rows' do
    assert_equal 2, matrix.length
  end

  it 'has 3 columns' do
    assert(matrix.all? { |row| row.length == 3 })
  end

  it 'has nils' do
    assert_equal [[nil, nil, nil], [nil, nil, nil]], matrix
  end
end

describe 'make_matrix' do
  matrix = make_matrix(3, 2) { |i, j| i == j ? 1 : 0 }

  it 'has 3 rows' do
    assert_equal 3, matrix.length
  end

  it 'has 2 columns' do
    assert(matrix.all? { |row| row.length == 2 })
  end

  it 'is identity' do
    assert_equal [[1, 0], [0, 1], [0, 0]], matrix
  end
end

describe 'next_value' do
  it 'works' do
    assert_equal(-1, next_value(0, -3))
    assert_equal(-1, next_value(0, -2))
    assert_equal(-1, next_value(0, -1))
    assert_equal 0, next_value(0, 0)
    assert_equal 1, next_value(0, 1)
    assert_equal 1, next_value(0, 2)
    assert_equal 1, next_value(0, 3)

    assert_equal 0, next_value(1, -3)
    assert_equal 0, next_value(1, -2)
    assert_equal 0, next_value(1, -1)
    assert_equal 0, next_value(1, 0)
    assert_equal 1, next_value(1, 1)
    assert_equal 2, next_value(1, 2)
    assert_equal 2, next_value(1, 3)
  end
end
