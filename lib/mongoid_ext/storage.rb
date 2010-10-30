module MongoidExt
  module Storage
    def self.included(model)
      model.class_eval do
        extend ClassMethods

        validate :add_mm_storage_errors
        file_list :file_list
      end
    end

    def put_file(name, io, options = {})
      file_list = send(options.delete(:in) || :file_list)
      file_list.put(name, io, options)
    end

    def fetch_file(name, options = {})
      file_list = send(options.delete(:in) || :file_list)
      file_list.get(name)
    end

    def files(options = {})
      file_list = send(options.delete(:in) || :file_list)
      file_list.files
    end

    def mm_storage_errors
      @mm_storage_errors ||= {}
    end

    def add_mm_storage_errors
      mm_storage_errors.each do |k, msgs|
        msgs.each do |msg|
          self.errors.add(k, msg)
        end
      end
    end

    module ClassMethods
      def gridfs
        @gridfs ||= Mongo::Grid.new(self.db)
      end

      def file_list(name)
        field name, :type => MongoidExt::FileList
        define_method(name) do
          list = self[name]

          if list.nil?
            list = self[name] = MongoidExt::FileList.new
          elsif list.class == BSON::OrderedHash || list.class == Hash
            list = MongoidExt::FileList.from_hash(list)
          end

          list.parent_document = self
          list
        end

        set_callback(:create, :after) do |doc|
          l = doc.send(name)
          l.sync_files
          doc.save(:validate => false)
        end

        set_callback(:destroy, :before) do |doc|
          doc.send(name).destroy_files
        end
      end

      def file_key(name, opts = {})
        opts[:in] ||= :file_list

        define_method("#{name}=") do |file|
          if opts[:max_length] && file.respond_to?(:size) && file.size > opts[:max_length]
            errors.add(name, I18n.t("mongoid_ext.storage.errors.max_length", :default => "file is too long. max length is #{opts[:max_length]} bytes"))
          end

          if cb = opts[:validate]
            if cb.kind_of?(Symbol)
              send(opts[:validate], file)
            elsif cb.kind_of?(Proc)
              cb.call(file)
            end
          end

          if self.errors.on(name).blank?
            send(opts[:in]).get(name.to_s).put(name.to_s, file)
          else
            # we store the errors here because we want to validate before storing the file
            mm_storage_errors.merge!(errors.errors)
          end
        end

        define_method(name) do
          send(opts[:in]).get(name.to_s)
        end

        define_method("has_#{name}?") do
          send(opts[:in]).has_key?(name.to_s)
        end
      end
      private
    end
  end
end
