module MongoidExt
  module Encryptor
    extend ActiveSupport::Concern

    included do
      require 'encryptor'
    end

    module ClassMethods
      def encrypted_field(name, options = {})
        key = options.delete(:key)
        raise ArgumentError, ":key option must be given" if key.nil?

        field(name, options)
        alias_method :"#{name}_encrypted", name

        define_method(name) do
          value = [send(:"#{name}_encrypted").to_s].pack('H*')

          return if value.blank?
          Marshal.load(::Encryptor.decrypt(value, :key => key))
        end

        define_method("#{name}=") do |v|
          marshaled = Marshal.dump(v)
          enc_value = ::Encryptor.encrypt(marshaled, :key => key).unpack('H*')[0]

          attributes[name.to_s] = enc_value
        end
      end
    end
  end
end
