module StreamRails

  module SyncPolicy

    module SyncCreate

      def self.included(base)
        base.after_commit :add_to_feed, on: :create
      end

      private
      def add_to_feed
        begin
          StreamRails.feed_manager.created_activity(self)
        rescue Exception => e
          StreamRails.logger.error "Something went wrong creating an activity: #{e}"
          raise
        end
      end
    end

    module SyncDestroy

      def self.included(base)
        base.after_commit :remove_from_feed, on: :destroy
      end

      private
      def remove_from_feed
        begin
          StreamRails.feed_manager.destroyed_activity(self)
        rescue Exception => e
          StreamRails.logger.error "Something went wrong deleting an activity: #{e}"
          raise
        end
      end
    end

  end
end
