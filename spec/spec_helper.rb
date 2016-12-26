require 'rubygems'
require 'bundler'

Bundler.setup(:default, :test, :development)
$LOAD_PATH.unshift File.expand_path('../../lib/', __FILE__)

require 'simplecov'
SimpleCov.start

require 'fakeweb'
FakeWeb.register_uri(
  :any,
  %r{https://us-east-api\.getstream\.io/},
  body: '{}'
)

require 'active_record'
ActiveRecord::Base.establish_connection(adapter: 'sqlite3',
                                        database: ':memory:')

require 'stream'
require 'stream_rails'

StreamRails.configure do |config|
  config.api_key     = 'key'
  config.api_secret  = 'secret'
  config.api_site_id = '42'
  config.location    = 'us-east'
  config.enabled     = true
end
