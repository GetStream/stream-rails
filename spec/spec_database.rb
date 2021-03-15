class User < ActiveRecord::Base
end
ActiveRecord::Migration.create_table :users

class Location < ActiveRecord::Base
end
ActiveRecord::Migration.create_table :locations
ActiveRecord::Migration.add_column(:locations, :name, :string, limit: 60)

class BaseModel < ActiveRecord::Base
  self.abstract_class = true
  validates_presence_of :user
  belongs_to :user
end

class Article < BaseModel
  include StreamRails::Activity
  as_activity

  attr_accessor :extra_data

  def activity_object
    self
  end

  def activity_extra_data
    @extra_data
  end
end

class Tweet < BaseModel
  belongs_to :user

  def activity_extra_data
    {
      parent_tweet: 1,
      parent_author: 2
    }
  end

  def activity_object
    self
  end

  def activity_target
    self
  end

  def activity_notify
    [StreamRails.feed_manager.get_notification_feed('cesar')]
  end

  include StreamRails::Activity
  as_activity track_deletes: false
end

class PoorlyImplementedActivity < BaseModel
  include StreamRails::Activity
  as_activity track_deletes: false
end

module CustomPolicy
  def self.included(base)
    base.before_create :custom_save
  end

  def custom_save; end
end

class Pin < BaseModel
  def activity_actor
    'cesar'
  end

  def activity_object
    'non AR object'
  end

  include StreamRails::Activity
  as_activity sync_policy: CustomPolicy
end

require 'sequel'
SEQUEL_DB = Sequel.sqlite

SEQUEL_DB.create_table?(:sequel_articles) do
  primary_key :id
  Integer :user_id
  String :title
  String :body
end

class SequelArticle < Sequel::Model
  include StreamRails::Activity
  as_activity

  many_to_one :user
  attr_accessor :extra_data

  def activity_object
    self
  end

  def activity_extra_data
    @extra_data
  end
end
SequelArticle.db = SEQUEL_DB
