require 'ostruct'

class OpenStruct
  def self.set(value)
    value.nil? ? nil : value.to_hash
  end

  def self.get(value)
    value.nil? ? nil : OpenStruct.new(value || {})
  end

  def to_hash
    send(:table)
  end
end
