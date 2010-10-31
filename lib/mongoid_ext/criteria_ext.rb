module MongoidExt
  module CriteriaExt
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
    end

    module InstanceMethods
    end
  end
end
Mongoid::Criteria.send(:include, MongoidExt::CriteriaExt)
