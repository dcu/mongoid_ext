module MongoidExt
  class FileList < Hash
    attr_accessor :parent_document

    def self.set(value)
      result = {}
      (value||{}).each do |k, v|
        result[k] = v.to_mongo
      end

      result
    end

    def self.get(value)
      return value if value.kind_of?(self)

      result = FileList.new
      (value||{}).each do |k, v|
        result[k] = v.kind_of?(MongoidExt::File) ? v : MongoidExt::File.new(v)
      end

      result
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
      file = self[id]
      if file.nil?
        file = self[id] = MongoidExt::File.new
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
