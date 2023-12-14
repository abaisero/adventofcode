# frozen_string_literal: true

# FrozenArray
module FrozenArray
  def self.new(array = nil)
    array = array.nil? ? [] : array.clone
    array.freeze
  end

  def self.concat(array, other)
    FrozenArray.new array + other
  end

  def self.append(array, obj)
    FrozenArray.new array + [obj]
  end

  def self.prepend(array, obj)
    FrozenArray.new [obj] + array
  end

  # how is this working..?  array should be frozen..?
  def self.pop(array)
    array = array.dup
    obj = array.pop
    array = FrozenArray.new array
    [array, obj]
  end
end

# FrozenHash
module FrozenHash
  def self.new(hash = nil)
    hash = hash.nil? ? {} : hash.clone
    hash.freeze
  end

  def self.set(hash, key, value)
    hash = hash.dup
    hash[key] = value
    FrozenHash.new hash
  end
end
