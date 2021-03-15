require 'spec_helper'
require 'spec_database'

describe 'StreamRails::SyncPolicies' do
  describe 'Sequel ORM integration' do
    describe 'after create hook' do
      it 'should create an activity' do
        expect_any_instance_of(SequelArticle).to receive(:add_to_feed)
        SequelArticle.create
      end
    end

    describe 'before destroy hook' do
      it 'should destroy an activity' do
        SequelArticle.any_instance.stub(:add_to_feed)
        article = SequelArticle.create
        expect_any_instance_of(SequelArticle).to receive(:remove_from_feed)
        article.destroy
      end
    end
  end
end
