class EmbeddedHash < Hash
  include ActiveModel::Validations

  def initialize(other = {})
    other.each do |k,v|
      self[k] = v
    end
    self["_id"] ||= BSON::ObjectId.new.to_s
  end

  def self.field(name, opts = {})
    define_method(name) do
      self[name.to_s] ||= opts[:default].kind_of?(Proc) ? opts[:default].call : opts[:default]
    end

    define_method("#{name}=") do |v|
      self[name.to_s] = v
    end
  end

  def id
      self["_id"]
  end
  alias :_id :id
end
