module StreamRails
  # Class used to initialize configuration object.
  class Config
    attr_accessor :api_key
    attr_accessor :api_secret
    attr_accessor :api_site_id
    attr_accessor :enabled

    def initialize
      @enabled    = true
    end

  end
end
