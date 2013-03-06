module MongoidExt
  module Tags
    def self.included(klass)
      klass.class_eval do
        extend ClassMethods

        field :tags, :type => Array, :default => []
        index({:tags => 1})
      end
    end

    module ClassMethods
      def tag_cloud(conditions = {}, limit = 30)
        pipeline = []
        if !conditions.blank?
          match = {:$match => conditions }
          pipeline << match
        end

        pipeline <<  {:$project => {:tags => 1}}
        pipeline <<  {:$unwind => "$tags"}
        pipeline <<  {:$group => {:_id => "$tags", :count => { :$sum => 1}}}
        pipeline <<  {:$project => {:_id => 0, :name => '$_id', :count => 1}}
        pipeline <<  {:$sort => {:count => -1}}
        pipeline <<  {:$limit => limit}
        self.collection.aggregate(pipeline)
      end

      # Model.find_with_tags("budget", "big").limit(4)
      def find_with_tags(*tags)
        self.where({:tags.in => tags})
      end

      def find_tags(regex, conditions = {}, limit = 30)
        pipeline = []
        if regex.is_a? String
          regex = /#{Regexp.escape(regex)}/
        end
        match = {:$match => {:tags => {:$in => [regex]}}}

        if !conditions.blank?
          match[:$match].merge! conditions
        end
        pipeline << match

        pipeline <<  {:$project => {:tags => 1}}
        pipeline <<  {:$unwind => "$tags"}
        pipeline <<  {:$match => {:tags => regex}}
        pipeline <<  {:$group => {:_id => "$tags", :count => { :$sum => 1}}}
        pipeline <<  {:$project => {:_id => 0, :name => '$_id', :count => 1}}
        pipeline <<  {:$sort => {:count => -1}}
        pipeline <<  {:$limit => limit}
        self.collection.aggregate(pipeline)
      end
    end
  end
end
