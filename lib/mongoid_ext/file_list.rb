module MongoidExt
  class FileList < EmbeddedHash
    attr_accessor :parent_document

    def put(id, io, metadata = {})
      if !parent_document.new_record?
        filename = id
        if io.respond_to?(:original_filename)
          filename = io.original_filename
        elsif io.respond_to?(:path) && io.path
          filename = ::File.basename(io.path)
        elsif io.kind_of?(String)
          io = StringIO.new(io)
        end

        get(id).put(filename, io, metadata)
      else
        (@_pending_files ||= {})[id] = [io, metadata]
      end
    end

    def files
      ids = self.keys
      ids.delete("_id")
      ids.map {|v| get(v) }
    end

    def each_file(&block)
      (self.keys-["_id"]).each do |key|
        file = self.get(key)
        yield key, file
      end
    end

    def get(id)
      if id.kind_of?(MongoidExt::File)
        self[id.id] = id
        return id
      end

      id = id.to_s.gsub(".", "_")
      file = self[id]
      if file.nil?
        file = self[id] = MongoidExt::File.new
      elsif file.class == BSON::OrderedHash
        file = self[id] = MongoidExt::File.new(file)
      end

      file._root_document = parent_document
      file
    end

    def sync_files
      if @_pending_files
        @_pending_files.each do |filename, data|
          put(filename, data[0], data[1])
        end
        @_pending_files = nil
      end
    end

    def delete(id)
      file = self.get(id)
      super(id)
      file.delete
    end

    def destroy_files
      each_file do |id, file|
        get(id).delete
      end
    end
  end
end
