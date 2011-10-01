require 'ostruct'

class OpenStruct
  include Mongoid::Fields::Serializable

  def serialize(value)
    value.nil? ? nil : value.to_hash
  end

  def deserialize(value)
    value.nil? ? nil : OpenStruct.new(value || {})
  end

  def to_hash
    send(:table)
  end
end
