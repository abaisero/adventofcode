# frozen_string_literal: true

# LinAlg
module LinAlg
  def self.add(a, b)
    a.zip(b).map { |x, y| x + y }
  end

  def self.subtract(a, b)
    a.zip(b).map { |x, y| x - y }
  end

  def self.l1_norm(array)
    array.map(&:abs).sum
  end

  def self.inf_norm(array)
    array.map(&:abs).max
  end

  def self.l1_dist(a, b)
    l1_norm subtract(a, b)
  end

  def self.inf_dist(a, b)
    inf_norm subtract(a, b)
  end
end
