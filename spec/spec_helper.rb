require 'rubygems'
require 'bundler'

Bundler.setup(:default, :test, :development)
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'simplecov'
SimpleCov.start

require 'active_record'
ActiveRecord::Base.establish_connection(adapter: 'sqlite3',
                                        database: ':memory:')

require 'stream'
require 'stream_rails'

StreamRails.configure do |config|
  config.api_key      = ENV.fetch('STREAM_API_KEY', nil) || 'YOUR_API_KEY'
  config.api_secret   = ENV.fetch('STREAM_API_SECRET', nil) || 'YOUR_API_SECRET'
  config.api_site_id  = '42'
  config.location     = ENV.fetch('STREAM_REGION', nil) || 'api'
  config.api_hostname = ENV.fetch('STREAM_API_HOSTNAME', nil)
  config.enabled      = false
end
