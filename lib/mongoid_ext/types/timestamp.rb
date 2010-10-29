class Timestamp
  def self.get(value)
    if value.nil? || value == ''
      nil
    else
      Time.zone.at(value.to_i)
    end
  end

  def self.set(value)
    value.to_i
  end
end

Time.zone ||= 'UTC'
