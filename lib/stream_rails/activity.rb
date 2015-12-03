require 'active_record'
require 'stream_rails/sync_policies'

module StreamRails

  class << self
    def create_reference(record)
      if record.is_a? ActiveRecord::Base
        "#{record.class.model_name}:#{record.id}"
      else
        record.to_s unless record.nil?
      end
    end
  end

  module ClassMethods

    def as_activity(opts = {})
      default_opts = {:track_deletes => true, :sync_policy => nil}
      options = default_opts.merge(opts)
      if options[:sync_policy].nil?
        include StreamRails::SyncPolicy::SyncCreate
        if options[:track_deletes]
          include StreamRails::SyncPolicy::SyncDestroy
        end
      else
        include options[:sync_policy]
      end
    end

  end

  module Activity

    def self.included base
      base.extend ClassMethods
    end

    def activity_owner_id
      self.activity_actor.id
    end

    def activity_actor
      self.user
    end

    def activity_owner_feed
      'user'
    end

    def activity_actor_id
      StreamRails.create_reference(self.activity_actor)
    end

    def activity_object
      raise NotImplementedError, "Activity models must define `#activity_object`"
    end

    def activity_verb
      self.class.model_name.to_s
    end

    def activity_object_id
      StreamRails.create_reference(self.activity_object)
    end

    def activity_foreign_id
      StreamRails.create_reference(self)
    end

    def activity_notify
    end

    def activity_extra_data
      {}
    end

    def activity_time
      self.created_at.iso8601
    end

    def create_activity
      activity = {
        :actor => self.activity_actor_id,
        :verb => self.activity_verb,
        :object => self.activity_object_id,
        :foreign_id => self.activity_foreign_id,
        :time => self.activity_time,
      }
      if !self.activity_notify.nil?
        activity[:to] = self.activity_notify.map{|f| f.id}
      end
      activity.merge(self.activity_extra_data)
    end

  end
end
