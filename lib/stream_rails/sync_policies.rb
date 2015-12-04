module StreamRails

  module SyncPolicy

    module SyncCreate

      def self.included(base)
        if base.respond_to? :after_commit
          base.after_commit :add_to_feed, on: :create
        else
          base.after_create :add_to_feed
        end
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
        if base.respond_to? :after_commit
          base.after_commit :remove_from_feed, on: :destroy
        else
          base.after_destroy :remove_from_feed
        end
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
