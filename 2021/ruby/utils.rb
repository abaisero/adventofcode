# frozen_string_literal: true

def make_matrix(nrows, ncols, default = nil)
  Array.new(nrows) { |i| Array.new(ncols) { |j| block_given? ? yield(i, j) : default } }
end

def valid_indices?(matrix, index_i, index_j)
  index_i.between?(0, matrix.length - 1) &&
    index_j.between?(0, matrix[index_i].length - 1)
end

def row_indices(matrix)
  0.upto(matrix.length - 1).to_a
end

def col_indices(matrix)
  0.upto(matrix.first.length - 1).to_a
end

def all_indices(matrix)
  row_indices(matrix).product(col_indices(matrix))
end

def apply_indices_deltas(index_i, index_j, deltas)
  deltas.map { |di, dj| [index_i + di, index_j + dj] }
end

def next_value(from, to)
  # returns the next value from x to y
  from + (to <=> from)
end
