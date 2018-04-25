module StreamRails
  # Class used to initialize configuration object.
  class Config
    attr_accessor :api_key
    attr_accessor :api_secret
    attr_accessor :location
    attr_accessor :api_hostname
    attr_accessor :api_site_id
    attr_accessor :enabled
    attr_accessor :timeout

    attr_accessor :news_feeds
    attr_accessor :notification_feed
    attr_accessor :user_feed

    def initialize
      @enabled    = true
      @news_feeds = { timeline: 'timeline', timeline_aggregated: 'timeline_aggregated' }
      @notification_feed = 'notification'
      @user_feed = 'user'
      @timeout = 3
    end

    def feed_configs
      { news_feeds: @news_feeds,
        notification_feed: @notification_feed,
        user_feed: @user_feed }
    end
  end
end
