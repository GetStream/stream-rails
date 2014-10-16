module StreamRails

  autoload :VERSION

  # Returns StreamRails's configuration object.
  def self.config
    @config ||= StreamRails::Config.new
  end

  # Lets you set global configuration options.
  #
  # All available options and their defaults are in the example below:
  # @example Initializer for Rails
  #   StreamRails.configure do |config|
  #     config.api_key     = "key"
  #     config.api_secret  = "secret"
  #     config.api_site_id = "42"
  #     config.enabled     = true
  #   end
  def self.configure(&block)
    yield(config) if block_given?
  end

end