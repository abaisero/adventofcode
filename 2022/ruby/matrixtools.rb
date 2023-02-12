# frozen_string_literal: true

# MatrixTools
module MatrixTools
  def self.make_matrix(nrows, ncols, default = nil)
    Array.new(nrows) { |i| Array.new(ncols) { |j| block_given? ? yield([i, j]) : default } }
  end

  def self.shape(matrix)
    nrows = matrix.length
    ncols = matrix.first.length
    [nrows, ncols]
  end

  def self.in_shape?(indices, shape)
    indices.zip(shape).all? { |i, s| i.between? 0, s - 1 }
  end

  def self.valid_indices?(matrix, i, j)
    i.between?(0, matrix.length - 1) && j.between?(0, matrix[i].length - 1)
  end

  def self.row_indices(matrix)
    0.upto(matrix.length - 1).to_a
  end

  def self.col_indices(matrix)
    0.upto(matrix.first.length - 1).to_a
  end

  def self.indices(matrix)
    row_indices(matrix).product(col_indices(matrix))
  end

  def self.find_index(matrix)
    indices(matrix).find { |index| block_given? ? yield(index) : matrix.dig(*index) }
  end

  def self.apply_indices_deltas(index_i, index_j, deltas)
    deltas.map { |di, dj| [index_i + di, index_j + dj] }
  end
end
