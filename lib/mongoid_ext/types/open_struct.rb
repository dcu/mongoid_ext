require 'ostruct'

class OpenStruct
  def self.set(value)
    if value.kind_of?(self)
      value.send(:table)
    else
      value
    end
  end

  def self.get(value)
    if value.kind_of?(self)
      value
    else
      OpenStruct.new(value || {})
    end
  end
end
