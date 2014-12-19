require 'active_support'
require 'action_view'
require 'stream'
require 'stream_rails/enrich'
require 'stream_rails/logger'

module StreamRails
  extend ActiveSupport::Autoload

  autoload :Activity
  autoload :Config
  autoload :FeedManager,  'stream_rails/feed_manager'
  autoload :Renderable
  autoload :VERSION

  def self.client
    Stream::Client.new(
      self.config.api_key,
      self.config.api_secret,
      self.config.api_site_id,
      :location => self.config.location
    )
  end

  # Returns StreamRails's configuration object.
  def self.config
    @config ||= StreamRails::Config.new
  end

  # Switches StreamRails on or off.
  # @param value [Boolean]
  def self.enabled=(value)
    StreamRails.config.enabled = value
  end

  # Returns `true` if StreamRails is on, `false` otherwise.
  # Enabled by default.
  # @return [Boolean]
  def self.enabled?
    !!StreamRails.config.enabled
  end

  # Returns StreamRails's configuration object.
  def self.feed_manager
    @feed_manager ||= StreamRails::FeedManager.new(self.client, self.config.feed_configs)
  end

  # Lets you set global configuration options.
  #
  # All available options and their defaults are in the example below:
  # @example Initializer for Rails
  #   StreamRails.configure do |config|
  #     config.api_key     = "key"
  #     config.api_secret  = "secret"
  #     config.api_site_id = "42"
  #     config.location    = "us-east"
  #     config.enabled     = true
  #   end
  def self.configure(&block)
    yield(config) if block_given?
  end

end

require 'stream_rails/utils/view_helpers'
require 'stream_rails/railtie' if defined?(Rails)
