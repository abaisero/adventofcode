# frozen_string_literal: true

def l1_norm(array1, array2)
  array1.zip(array2).map { |x, y| (x - y).abs }.sum
end

def inf_norm(array1, array2)
  array1.zip(array2).map { |x, y| (x - y).abs }.max
end
