class User < ActiveRecord::Base
end

ActiveRecord::Migration.create_table :users

class BaseModel < ActiveRecord::Base
  self.abstract_class = true
  validates_presence_of :user
  belongs_to :user
end

class Article < BaseModel

  include StreamRails::Activity
  as_activity

  def activity_object
    self
  end

end

class Tweet < BaseModel
  belongs_to :user

  def activity_extra_data
    {
      :parent_tweet => 1,
      :parent_author => 2
    }
  end

  def activity_object
    self
  end

  def activity_notify
    [StreamRails.feed_manager.get_notification_feed('cesar')]
  end

  include StreamRails::Activity
  as_activity :track_deletes => false
end

module CustomPolicy

  def self.included(base)
    base.before_create :custom_save
  end

  def custom_save
  end

end

class Pin < BaseModel

  def activity_actor
    'cesar'
  end

  def activity_object
    'non AR object'
  end

  include StreamRails::Activity
  as_activity :sync_policy => CustomPolicy
end
