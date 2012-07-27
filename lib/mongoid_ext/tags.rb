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
        Mongoid.session(:default).command({
          :eval => "function(collection, q,l) { return tag_cloud(collection, q,l); }",
          :args => [self.collection_name, conditions, limit]
        })['retval']
      end

      # Model.find_with_tags("budget", "big").limit(4)
      def find_with_tags(*tags)
        self.where({:tags.in => tags})
      end

      def find_tags(regex, conditions = {}, limit = 30)
        Mongoid.session(:default).command({
          :eval => "function(collection, a,b,c) { return find_tags(collection, a,b,c); }",
          :args => [self.collection_name, regex, conditions, limit]
        })['retval']
      end
    end
  end
end
