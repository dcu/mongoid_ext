$:.unshift File.dirname(__FILE__)

if RUBY_VERSION =~ /^1\.8/
  $KCODE = 'u'
end

require 'mongoid'
require 'uuidtools'
require 'differ'
require 'active_support/inflector'

begin
  require 'magic'
rescue LoadError
  $stderr.puts "disabling `magic` support. use 'gem install magic' to enable it"
end

require 'mongoid_ext/patches'

# types
require 'mongoid_ext/types/open_struct'
require 'mongoid_ext/types/timestamp'
require 'mongoid_ext/types/translation'
require 'mongoid_ext/types/embedded_hash'

# storage
require 'mongoid_ext/file_list'
require 'mongoid_ext/file'
require 'mongoid_ext/storage'
require 'mongoid_ext/file_server'

# update
require 'mongoid_ext/update'

# filter
require 'mongoid_ext/filter'
require 'mongoid_ext/filter/parser'
require 'mongoid_ext/filter/result_set'

# slug
require 'mongoid_ext/slugizer'

# tags
require 'mongoid_ext/tags'

require 'mongoid_ext/versioning'
require 'mongoid_ext/voteable'
require 'mongoid_ext/paranoia'

require 'mongoid_ext/random'
require 'mongoid_ext/mongo_mapper'
require 'mongoid_ext/document_ext'
require 'mongoid_ext/criteria_ext'
require 'mongoid_ext/modifiers'

module MongoidExt
  def self.init
    load_jsfiles(::File.dirname(__FILE__)+"/mongoid_ext/js")
  end

  def self.load_jsfiles(path)
    Dir.glob(::File.join(path, "*.js")) do |js_path|
      code = ::File.read(js_path)
      name = ::File.basename(js_path, ".js")

      # HACK: looks like ruby driver doesn't support this
      Mongoid.master.eval("db.system.js.save({_id: '#{name}', value: #{code}})")
    end
  end
end

