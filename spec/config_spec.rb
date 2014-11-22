require 'spec_helper'

describe StreamRails do

  describe ".configure" do
    it "allows configuring api_key" do
      StreamRails.configure do |config|
        config.api_key = 'apikey'
      end
      StreamRails.config.api_key.should eq 'apikey'
    end

    it "allows configuring api_secret" do
      StreamRails.configure do |config|
        config.api_secret = 'apisecret'
      end
      StreamRails.config.api_secret.should eq 'apisecret'
    end

    it "is enabled by default" do
      StreamRails.config.enabled.should eq true
    end

    it "can be disabled" do
      StreamRails.enabled = false
      StreamRails.config.enabled.should eq false
      StreamRails.enabled?.should eq false
      StreamRails.enabled = true
    end

    it "should have default feed configs" do
      feed_configs = StreamRails.config.feed_configs
    end

  end
end