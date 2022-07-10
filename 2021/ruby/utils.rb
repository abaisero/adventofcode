# frozen_string_literal: true

def valid_indices?(matrix, index_i, index_j)
  index_i >= 0 && index_j >= 0 && index_i < matrix.length && index_j < matrix[index_i].length
end

def row_indices(matrix)
  (0...matrix.length).to_a
end

def col_indices(matrix)
  (0...matrix.first.length).to_a
end

def all_indices(matrix)
  row_indices(matrix).product(col_indices(matrix))
end

def apply_indices_deltas(index_i, index_j, deltas)
  deltas.map { |di, dj| [index_i + di, index_j + dj] }
end
