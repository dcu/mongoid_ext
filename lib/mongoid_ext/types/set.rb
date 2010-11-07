class Set
  def self.set(value)
    value.kind_of?(Set) ? value.to_a : value
  end
end
