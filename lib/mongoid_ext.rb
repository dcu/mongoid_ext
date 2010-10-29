$:.unshift File.dirname(__FILE__)

if RUBY_VERSION =~ /^1\.8/
  $KCODE = 'u'
end

require 'mongo_mapper'
require 'uuidtools'
require 'active_support/inflector'

begin
  require 'magic'
rescue LoadError
  $stderr.puts "disabling `magic` support. use 'gem install magic' to enable it"
end

require 'mongoid_ext/paginator'

# types
require 'mongoid_ext/types/open_struct'
require 'mongoid_ext/types/timestamp'
require 'mongoid_ext/types/translation'

# storage
require 'mongoid_ext/file_list'
require 'mongoid_ext/file'
require 'mongoid_ext/storage'
require 'mongoid_ext/file_server'

# update
require 'mongoid_ext/update'

# filter
require 'mongoid_ext/filter'

# slug
require 'mongoid_ext/slugizer'

# tags
require 'mongoid_ext/tags'

module MongoidExt
  def self.init
    load_jsfiles(::File.dirname(__FILE__)+"/mongoid_ext/js")
  end

  def self.load_jsfiles(path)
    Dir.glob(::File.join(path, "*.js")) do |js_path|
      code = ::File.read(js_path)
      name = ::File.basename(js_path, ".js")

      # HACK: looks like ruby driver doesn't support this
      Mongoid.config.database.eval("db.system.js.save({_id: '#{name}', value: #{code}})")
    end
  end
end
