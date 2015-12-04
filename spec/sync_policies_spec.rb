require 'spec_helper'
require 'spec_database'

describe 'StreamRails::SyncPolicies' do
  describe "Sequel ORM intregation" do
    describe "after create hook" do
      it "should create an activity" do
        SequelArticle.any_instance.should_receive(:add_to_feed)
        SequelArticle.create
      end
    end

    describe "before destroy hook" do
      it "should destroy an activity" do
        SequelArticle.any_instance.stub(:add_to_feed)
        article = SequelArticle.create
        SequelArticle.any_instance.should_receive(:remove_from_feed)
        article.destroy
      end
    end
  end
end
