require 'rubygems'

gem 'jnunemaker-matchy'

require 'matchy'
require 'shoulda'
require 'timecop'
require 'mocha'
require 'pp'
require 'pry'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'support/custom_matchers'
require 'mongoid_ext'

Mongoid.load!("test/mongoid.yml", "test")
require 'models'


class Test::Unit::TestCase
  include CustomMatchers
end

MongoidExt.init

$VERBOSE=nil
