require 'active_record'
require 'spec_helper'
require 'spec_database'

describe 'activity class implementations' do
  before do
    @tom = User.new
    @tom.save!

    @denver = Location.new
    @denver.name = 'Denver, CO'
    @denver.save!
  end

  def use_model(activity_model)
    @activity_model = activity_model
    ActiveRecord::Migration.create_table activity_model.table_name do |t|
      t.integer :user_id
      t.timestamps
    end
  end

  def has_activity_methods
    instance = @activity_model.new
    expect(instance).to respond_to(:activity_actor_id)
    expect(instance).to respond_to(:activity_verb)
    expect(instance).to respond_to(:activity_target)
    expect(instance).to respond_to(:activity_object_id)
    expect(instance).to respond_to(:activity_target_id)
    expect(instance).to respond_to(:activity_notify)
    expect(instance).to respond_to(:activity_extra_data)
    expect(instance).to respond_to(:activity_should_sync?)
    expect(instance).to respond_to(:create_activity)
  end

  def try_delete
    instance = @activity_model.new
    instance.user = @tom
    instance.save!
    instance.destroy
  end

  def build_activity_with_location
    instance = @activity_model.new
    instance.user = @tom
    instance.extra_data = { location: "location:#{@denver.id}" }
    instance.save!
    instance.create_activity
  end

  def build_activity
    instance = @activity_model.new
    instance.user = @tom
    instance.save!
    instance.create_activity
  end

  context 'Article' do
    before(:all) { use_model(Article) }
    specify { has_activity_methods }
    specify { try_delete }
    specify do
      activity = build_activity_with_location
      expect(activity[:to]).to eq nil
      expect(activity[:actor]).not_to eq nil
      expect(activity[:verb]).not_to eq nil
      expect(activity[:object]).not_to eq nil
    end
  end

  context 'Tweet' do
    before(:all) { use_model(Tweet) }
    specify { has_activity_methods }
    specify { try_delete }
    specify do
      activity = build_activity
      expect(activity[:actor]).not_to eq nil
      expect(activity[:verb]).not_to eq nil
      expect(activity[:object]).not_to eq nil
      expect(activity[:target]).not_to eq nil
      expect(activity[:parent_tweet]).to eq 1
      expect(activity[:parent_author]).to eq 2
      expect(activity[:to]).to eq ['notification:cesar']
    end
  end

  context 'Pin' do
    before(:all) { use_model(Pin) }
    specify { has_activity_methods }
    specify { expect(@activity_model.new).to respond_to(:custom_save) }
    specify { try_delete }
    specify do
      activity = build_activity
      expect(activity[:to]).to eq nil
      expect(activity[:actor]).to eq 'cesar'
      expect(activity[:verb]).not_to eq nil
      expect(activity[:object]).not_to eq nil
    end
  end

  context 'PoorlyImplementedActivity' do
    before(:all) { use_model(PoorlyImplementedActivity) }
    specify { has_activity_methods }
    specify do
      activity = PoorlyImplementedActivity.new

      error_message = 'Activity models must define `#activity_object` - missing on `PoorlyImplementedActivity`'
      expect { activity.activity_object }.to raise_error(NotImplementedError, error_message)
    end
  end
end
