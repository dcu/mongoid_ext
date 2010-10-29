module MongoidExt
  class File
    include Mongoid::Document

    key :_id, :type => String
    field :name, :type => String
    field :extension, :type => String
    field :content_type, :type => String

    alias :filename :name

    def put(filename, io, options = {})
      options[:_id] = grid_filename

      options[:metadata] ||= {}
      options[:metadata][:collection] = _root_document.collection.name

      self.name = filename
      if filename =~ /\.([\w]{2,4})$/
        self.extension = $1
      end

      if io.kind_of?(String)
        io = StringIO.new(io)
      end

      if defined?(Magic) && Magic.respond_to?(:guess_string_mime_type)
        data = io.read(256) # be nice with memory usage
        self.content_type = options[:content_type] = Magic.guess_string_mime_type(data.to_s)
        self.extension ||= options[:content_type].to_s.split("/").last.split("-").last

        if io.respond_to?(:rewind)
          io.rewind
        else
          io.seek(0)
        end
      end

      options[:filename] = grid_filename
      gridfs.delete(grid_filename)
      gridfs.put(io, options)
    end

    def get
      @io ||= gridfs.get(grid_filename)
    end

    def reset
      @io = nil
    end

    def grid_filename
      @grid_filename ||= "#{_root_document.collection.name}/#{self.id}"
    end

    def mime_type
      self.content_type || get.content_type
    end

    def size
      get.file_length
    end

    def read(size = nil)
      self.get.read(size)
    end

    def delete
      @io = nil
      gridfs.delete(grid_filename)
    end

    def method_missing(name, *args, &block)
      f = self.get rescue nil
      if f && f.respond_to?(name)
        f.send(name, *args, &block)
      else
        super(name, *args, &block)
      end
    end

    protected
    def gridfs
      _root_document.class.gridfs
    end
  end
end
