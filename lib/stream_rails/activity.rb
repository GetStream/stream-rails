require 'active_record'
require 'stream_rails/sync_policies'

module StreamRails
  class << self
    def create_reference(record)
      if record.is_a?(ActiveRecord::Base) || (Object.const_defined?('Sequel') && record.is_a?(Sequel::Model))
        "#{record.class.model_name}:#{record.id}"
      else
        record.to_s unless record.nil?
      end
    end
  end

  module ClassMethods
    def as_activity(opts = {})
      default_opts = { track_deletes: true, sync_policy: nil }
      options = default_opts.merge(opts)
      if options[:sync_policy].nil?
        include StreamRails::SyncPolicy::SyncCreate
        include StreamRails::SyncPolicy::SyncDestroy if options[:track_deletes]
      else
        include options[:sync_policy]
      end
    end
  end

  module Activity
    def self.included(base)
      base.extend ClassMethods
    end

    def activity_owner_id
      activity_actor.id
    end

    def activity_actor
      user
    end

    def activity_owner_feed
      'user'
    end

    def activity_actor_id
      StreamRails.create_reference(activity_actor)
    end

    def activity_object
      raise NotImplementedError, "Activity models must define `#activity_object` - missing on `#{self.class}`"
    end

    def activity_target
      nil
    end

    def activity_verb
      self.class.model_name.to_s
    end

    def activity_object_id
      StreamRails.create_reference(activity_object)
    end

    def activity_foreign_id
      StreamRails.create_reference(self)
    end

    def activity_target_id
      StreamRails.create_reference(activity_target) if activity_target
    end

    def activity_notify; end

    def activity_extra_data
      {}
    end

    def activity_time
      created_at.iso8601
    end

    def activity_should_sync?
      true
    end

    def create_activity
      activity = {
        actor: activity_actor_id,
        verb: activity_verb,
        object: activity_object_id,
        foreign_id: activity_foreign_id,
        target: activity_target_id,
        time: activity_time
      }
      arr = activity_notify
      activity[:to] = arr.map(&:id) unless arr.nil?
      activity.merge!(activity_extra_data || {})
    end
  end
end
