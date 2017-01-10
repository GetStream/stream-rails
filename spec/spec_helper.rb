require 'rubygems'
require 'bundler'

Bundler.setup(:default, :test, :development)
$LOAD_PATH.unshift File.expand_path('../../lib/', __FILE__)

require 'simplecov'
SimpleCov.start

require 'active_record'
ActiveRecord::Base.establish_connection(adapter: 'sqlite3',
                                        database: ':memory:')

require 'stream'
require 'stream_rails'

StreamRails.configure do |config|
  config.api_key     = ENV['STREAM_API_KEY']
  config.api_secret  = ENV['STREAM_API_SECRET']
  config.api_site_id = '42'
  config.location    = ENV['STREAM_REGION']
  config.enabled     = true
end
