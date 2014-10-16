require "rubygems"
require "bundler"
Bundler.setup(:default, :test, :development)
$:.unshift File.expand_path('../../lib/', __FILE__)

require 'fakeweb'
FakeWeb.register_uri(
  :any,
  %r|https://getstream\.io/|,
  :body => "{}"
)

require 'active_record'
ActiveRecord::Base.establish_connection(:adapter => "sqlite3",
                                       :database => ":memory:")

require 'stream'
require 'stream_rails'