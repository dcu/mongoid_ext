module MongoidExt
module Versioning
  def self.included(klass)
    klass.class_eval do
      extend ClassMethods
      include InstanceMethods

      cattr_accessor :versionable_options

      attr_accessor :rolling_back
      field :version_message

      field :versions_count, :type => Integer, :default => 0
      field :version_ids, :type => Array, :default => []

      before_save :save_version, :if => Proc.new { |d| !d.rolling_back }
    end
  end

  module InstanceMethods
    def rollback!(pos = nil)
      pos = self.versions_count-1 if pos.nil?
      version = self.version_at(pos)

      if version
        version.data.each do |key, value|
          self.send("#{key}=", value)
        end

        owner_field = self.class.versionable_options[:owner_field]
        self[owner_field] = version[owner_field] if !self.changes.include?(owner_field)
        self.updated_at = version.date if self.respond_to?(:updated_at) && !self.updated_at_changed?
      end

      @rolling_back = true
      save!
    end

    def load_version(pos = nil)
      pos = self.versions_count-1 if pos.nil?
      version = self.version_at(pos)

      if version
        version.data.each do |key, value|
          self.send("#{key}=", value)
        end
      end
    end

    def diff(key, pos1, pos2, format = :html)
      version1 = self.version_at(pos1)
      version2 = self.version_at(pos2)

      Differ.diff_by_word(version1.content(key), version2.content(key)).format_as(format).html_safe
    end

    def current_version
      version_klass.new(:data => self.attributes, self.class.versionable_options[:owner_field] => (self.updated_by_id_was || self.updated_by_id), :created_at => Time.now)
    end

    def version_at(pos)
      case pos.to_s
      when "current"
        current_version
      when "first"
        version_klass.find(self.version_ids.first)
      when "last"
        version_klass.find(self.version_ids.last)
      else
        if version_id = self.version_ids[pos]
          version_klass.find(self.version_ids[pos])
        end
      end
    end

    def versions
      version_klass.where(:target_id => self.id)
    end

    def version_klass
      self.class.version_klass
    end
  end

  module ClassMethods
    def version_klass
      parent_klass = self
      @version_klass ||= Class.new do
        include Mongoid::Document
        include Mongoid::Timestamps

        cattr_accessor :parent_class
        self.parent_class = parent_klass

        self.collection_name = "#{self.parent_class.collection_name}.versions"

        identity :type => String
        field :message, :type => String
        field :data, :type => Hash

        referenced_in :owner, :class_name => parent_klass.versionable_options[:user_class]

        referenced_in :target, :polymorphic => true

        after_create :add_version

        validates_presence_of :target_id

        def content(key)
          cdata = self.data[key]
          if cdata.respond_to?(:join)
            cdata.join(" ")
          else
            cdata || ""
          end
        end

        private
        def add_version
          self.class.parent_class.push({:_id => self.target_id}, {:version_ids => self.id})
          self.class.parent_class.increment({:_id => self.target_id}, {:versions_count => 1})
        end
      end
    end

    # example:
    #     class Foo
    #       include Mongoid::Document
    #       include MongoidExt::Versioning
    #       versionable_keys :field1, :field2, :field3, :user_class => "Customer", :owner_field => "updated_by_id"
    #       ...
    #     end
    #
    def versionable_keys(*keys)
      self.versionable_options = keys.extract_options!
      self.versionable_options[:owner_field] ||= "user_id"
      self.versionable_options[:owner_field] = self.versionable_options[:owner_field].to_s

      relationship = self.relations[self.versionable_options[:owner_field].sub(/_id$/, "")]
      if !relationship
        raise ArgumentError, "the supplied :owner_field => #{self.versionable_options[:owner_field].inspect} option is invalid"
      end
      self.versionable_options[:user_class] = relationship.class_name

      define_method(:save_version) do
        data = {}
        message = ""
        keys.each do |key|
          if change = changes[key.to_s]
            data[key.to_s] = change.first
          else
            data[key.to_s] = self[key]
          end
        end

        if message_changes = self.changes["version_message"]
          message = message_changes.first
        else
          version_message = ""
        end

        uuser_id = send(self.versionable_options[:owner_field]+"_was")||send(self.versionable_options[:owner_field])
        if !self.new? && !data.empty? && uuser_id
          max_versions = self.versionable_options[:max_versions].to_i
          if max_versions > 0 && self.version_ids.size >= max_versions
            old = self.version_ids.slice!(0, max_versions)
            self.class.skip_callback(:save, :before, :save_version)
            self.version_klass.delete(:_ids => old)
            self.save
            self.class.set_callback(:save, :before, :save_version)
          end

          self.version_klass.create({
            'data' => data,
            'owner_id' => uuser_id,
            'target' => self,
            'message' => message
          })
        end
      end

      define_method(:versioned_keys) do
        keys
      end
    end
  end
end
end

