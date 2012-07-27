class EmbeddedHash < Hash
  include ActiveModel::Validations

  def initialize(other = {})
    super()

    if other
      other.each do |k,v|
        self[k] = v
      end
    end

    self.assign_id
  end

  def self.allocate
    obj = super
    obj.assign_id

    obj
  end

  def self.field(name, opts = {})
    define_method(name) do
      if fetch(name.to_s, nil).nil?
        self[name.to_s] = opts[:default].kind_of?(Proc) ? opts[:default].call : opts[:default]
      else
        self[name.to_s]
      end
    end

    define_method("#{name}=") do |v|
      self[name.to_s] = v
    end
  end

  def id
    self["_id"]
  end
  alias :_id :id

  def self.mongoize(v)
    v
  end

  def self.demongoize(v)
    self.new(v)
  end

#   def method_missing(name, *args, &block)
#     @table.send(name, *args, &block)
#   end

  def assign_id
    if fetch("_id", nil).nil?
      self["_id"] = Moped::BSON::ObjectId.new.to_s
    end
  end
end
