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
        instance.class_eval do
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
    specify { feed_manager.client.should be_an_instance_of Stream::Client }
    specify { feed_manager.get_user_feed(1).should be_an_instance_of Stream::Feed }
    specify { feed_manager.get_user_feed(1).id.should eq 'user:1' }
    specify { feed_manager.get_news_feeds(1).should be_an_instance_of Hash }
    specify { feed_manager.get_news_feeds(1)[:flat].should be_an_instance_of Stream::Feed }
    specify { feed_manager.get_news_feeds(1)[:flat].id.should eq 'flat:1' }
    specify { feed_manager.get_news_feeds(1)[:aggregated].should be_an_instance_of Stream::Feed }
    specify { feed_manager.get_news_feeds(1)[:aggregated].id.should eq 'aggregated:1' }
    specify { feed_manager.get_notification_feed(1).should be_an_instance_of Stream::Feed }
    specify { feed_manager.get_feed('flat', 1).should be_an_instance_of Stream::Feed }
  end

  context 'follow and unfollow' do
    context 'StreamRails enabled' do
      let(:feed_manager) { StreamRails.feed_manager }

      specify do
        feed_manager.follow_user(1, 2)
        body = JSON.parse(FakeWeb.last_request.body)
        body['target'].should eq 'user:2'
      end
      specify do
        feed_manager.unfollow_user(1, 2)
        FakeWeb.last_request.method.should eq 'DELETE'
      end
    end

    context 'StreamRails disabled' do
      let(:feed_manager) { StreamRails.feed_manager }

      it 'should not call follow/unfollow API' do
        StreamRails.enabled = false

        feed_manager.should_not receive(:get_feed)
        feed_manager.follow_user(1, 2)

        feed_manager.should_not receive(:get_feed)
        feed_manager.unfollow_user(1, 2)
      end
    end
  end
end
