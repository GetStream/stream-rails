module StreamRails

  module SyncPolicy

    module SyncCreate

      def self.included(base)
        base.after_commit :add_to_feed, on: [:create]
      end

      private
      def add_to_feed
        StreamRails.feed_manager.created_activity(self)
      end
    end

    module SyncDestroy

      def self.included(base)
        base.after_commit :remove_from_feed, on: [:destroy]
      end

      private
      def remove_from_feed
        StreamRails.feed_manager.destroyed_activity(self)
      end
    end

  end
end
