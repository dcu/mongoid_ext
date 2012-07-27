class Timestamp
  def self.demongoize(value)
    if value.nil? || value == ''
      nil
    else
      ::Time.zone.at(value.to_i)
    end
  end

  def self.mongoize(value)
    value.to_i
  end
end

::Time.zone ||= 'UTC'
