module MongoidExt
  module Random
    extend ActiveSupport::Concern

    included do
      field :_random, :type => Float, :default => lambda{rand}
      field :_random_times, :type => Float, :default => 0.0

      index({:_random => 1})
      index({:_random_times => 1})
    end

    module ClassMethods
      def random(conditions = {})
        r = rand()
        doc = self.where(conditions.merge(:_random.gte => r)).order_by(:_random_times.asc, :_random.asc).first ||
              self.where(conditions.merge(:_random.lte => r)).order_by(:_random_times.asc, :_random.asc).first
        doc.inc(:_random_times, 1.0) if doc
        doc
      end
    end
  end
end
