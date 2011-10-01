class Timestamp
  include Mongoid::Fields::Serializable

  def deserialize(value)
    if value.nil? || value == ''
      nil
    else
      ::Time.zone.at(value.to_i)
    end
  end

  def serialize(value)
    value.to_i
  end
end

::Time.zone ||= 'UTC'
