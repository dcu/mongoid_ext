require 'ostruct'

module MongoidExt
  class OpenStruct < ::OpenStruct
    def mongoize
      send(:table)
    end

    def self.demongoize(value)
      value.nil? ? nil : OpenStruct.new(value)
    end

    def self.mongoize(value)
      if value.kind_of?(self)
        value.mongoize
      elsif value.kind_of?(Hash)
        value
      else
        nil
      end
    end
  end
end
