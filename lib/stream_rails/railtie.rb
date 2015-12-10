require 'rails'

module StreamRails
  class Railtie < ::Rails::Railtie
    initializer 'stream_rails.setup_logging' do
      StreamRails.logger = Rails.logger
    end
  end
end
