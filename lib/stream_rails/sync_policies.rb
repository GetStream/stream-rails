module StreamRails
  module SyncPolicy
    module SyncCreate
      def self.included(base)
        if base.respond_to? :after_commit
          base.after_commit :add_to_feed, on: :create
        elsif Object.const_defined?('Sequel') && base < Sequel::Model
          base.class_eval do
            define_method(:_after_create) do |*args|
              super(*args)
              add_to_feed
            end
          end
        else
          fail 'Your ORM is not supported'
        end
      end

      private

      def add_to_feed
        StreamRails.feed_manager.created_activity(self)
      rescue Exception => e
        StreamRails.logger.error "Something went wrong creating an activity: #{e}"
        raise
      end
    end

    module SyncDestroy
      def self.included(base)
        if base.respond_to? :after_commit
          base.after_commit :remove_from_feed, on: :destroy
        elsif Object.const_defined?('Sequel') && base < Sequel::Model
          base.instance_eval do
            define_method(:before_destroy) do |*args|
              remove_from_feed
              super(*args)
            end
          end
        else
          fail 'Your ORM is not supported'
        end
      end

      private

      def remove_from_feed
        StreamRails.feed_manager.destroyed_activity(self)
      rescue Exception => e
        StreamRails.logger.error "Something went wrong deleting an activity: #{e}"
        raise
      end
    end
  end
end
