module StreamRails
  # Class used to manage feeds
  class FeedManager
    attr_reader :client

    def initialize(client, opts = {})
      @client = client
      @user_feed = opts[:user_feed]
      @news_feeds = opts[:news_feeds]
      @notification_feed = opts[:notification_feed]
    end

    def get_user_feed(user_id)
      @client.feed(@user_feed, user_id)
    end

    def get_news_feeds(user_id)
      Hash[@news_feeds.map { |feed_name, feed_slug| [feed_name, get_feed(feed_slug, user_id)] }]
    end

    def get_notification_feed(user_id)
      @client.feed(@notification_feed, user_id)
    end

    def get_feed(feed_type, user_id)
      @client.feed(feed_type, user_id)
    end

    def follow_user(user_id, target_id)
      return unless StreamRails.enabled?
      target_feed = get_user_feed(target_id)
      @news_feeds.each do |_, feed|
        news_feed = get_feed(feed, user_id)
        news_feed.follow(target_feed.slug, target_feed.user_id)
      end
    end

    def unfollow_user(user_id, target_id)
      return unless StreamRails.enabled?
      target_feed = get_user_feed(target_id)
      @news_feeds.each do |_, feed|
        news_feed = get_feed(feed, user_id)
        news_feed.unfollow(target_feed.slug, target_feed.user_id)
      end
    end

    def get_owner_feed(instance)
      get_feed(instance.activity_owner_feed, instance.activity_owner_id)
    end

    def created_activity(instance)
      return unless StreamRails.enabled? && instance.activity_should_sync?
      activity = instance.create_activity
      feed = get_owner_feed(instance)
      feed.add_activity(activity)
    end

    def destroyed_activity(instance)
      return unless StreamRails.enabled?
      feed = get_owner_feed(instance)
      feed.remove(instance.activity_foreign_id, true)
    end
  end
end
