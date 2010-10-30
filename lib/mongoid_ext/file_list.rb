module MongoidExt
  class FileList < Hash
    attr_accessor :parent_document

    def self.from_hash(other)
      n = self.new
      other.each do |k,v|
        n[k] = v
      end
      n
    end

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
      self.values
    end

    def get(id)
      id = id.gsub(".", "_")
      file = self[id]

      if file.nil?
        file = self[id] = MongoidExt::File.new
      elsif file.class == BSON::OrderedHash
        file = self[id] = MongoidExt::File.from_hash(file)
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

    def destroy_files
      self.delete_if do |id, file|
        file._parent_document = parent_document
        file.delete
      end
    end
  end
end
