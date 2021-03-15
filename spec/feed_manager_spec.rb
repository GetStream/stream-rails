require 'spec_helper'
require 'spec_database'
require 'json'

describe 'StreamRails::FeedManager' do
  subject { feed_manager }

  context 'when instance should not sync' do
    let(:feed_manager) { StreamRails.feed_manager }
    describe '#created_activity' do
      let(:instance) { Article.new }
      it 'should not create activity' do
        instance.instance_eval do
          def activity_should_sync?
            false
          end
        end
        expect(instance).to_not receive(:create_activity)
        feed_manager.created_activity(instance)
      end
    end
  end

  context 'instance from StreamRails' do
    let(:feed_manager) { StreamRails.feed_manager }
    specify { expect(feed_manager.client).to be_an_instance_of Stream::Client }
    specify { expect(feed_manager.get_user_feed(1)).to be_an_instance_of Stream::Feed }
    specify { expect(feed_manager.get_user_feed(1).id).to eq 'user:1' }
    specify { expect(feed_manager.get_news_feeds(1)).to be_an_instance_of Hash }
    specify { expect(feed_manager.get_news_feeds(1)[:timeline]).to be_an_instance_of Stream::Feed }
    specify { expect(feed_manager.get_news_feeds(1)[:timeline].id).to eq 'timeline:1' }
    specify { expect(feed_manager.get_news_feeds(1)[:timeline_aggregated]).to be_an_instance_of Stream::Feed }
    specify { expect(feed_manager.get_news_feeds(1)[:timeline_aggregated].id).to eq 'timeline_aggregated:1' }
    specify { expect(feed_manager.get_notification_feed(1)).to be_an_instance_of Stream::Feed }
    specify { expect(feed_manager.get_feed('flat', 1)).to be_an_instance_of Stream::Feed }
  end

  context 'follow and unfollow' do
    context 'StreamRails disabled' do
      let(:feed_manager) { StreamRails.feed_manager }

      it 'should not call follow/unfollow API' do
        expect(feed_manager).not_to receive(:get_feed)
        feed_manager.follow_user(1, 2)

        expect(feed_manager).not_to receive(:get_feed)
        feed_manager.unfollow_user(1, 2)
      end
    end
  end
end
