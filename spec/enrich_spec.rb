require 'spec_helper'
require 'spec_database'

describe 'StreamRails::Enrich' do
  before do
    @employee1 = Employee.new
    @employee1.save!

    @employee2 = Employee.new
    @employee2.save!

    @enricher = StreamRails::Enrich.new
    @tom = User.new
    @tom.employee = @employee1
    @tom.save!

    @enricher_subref = StreamRails::Enrich.new(user: [:employee])
    @jane = User.new
    @jane.employee = @employee2
    @jane.save!

    @denver = Location.new
    @denver.name = 'Denver, CO'
    @denver.save!
  end

  def create_article
    instance = Article.new
    instance.user = @tom
    instance.extra_data = { location: "location:#{@denver.id}" }
    instance.save!

    @enricher.add_fields([:location])

    instance
  end

  def create_article_subref(round=nil)
    instance = Article.new
    if round.nil?
      instance.user = @jane
    else
      instance.user = @tom
    end
    instance.extra_data = { location: "location:#{@denver.id}" }
    instance.save!

    @enricher.add_fields([:location])

    instance
  end

  describe 'enricher' do
    describe 'has default settings for enriched fields' do
      enricher = StreamRails::Enrich.new
      enricher.fields.should == [:actor, :object, :target]
    end

    describe 'can add additional settings for enriched fields' do
      describe 'in the initializer' do
        describe 'as a flat list' do
          enricher = StreamRails::Enrich.new([:location])
          enricher.fields.should == [:actor, :object, :target, :location]
        end

        describe 'allowing for subreferences' do
          enricher = StreamRails::Enrich.new([location: [:tweet]])
          enricher.fields.should == [:actor, :object, :target, location: [:tweet]]
        end
      end

      describe 'using add_fields' do
        describe 'as a flat list' do
          enricher = StreamRails::Enrich.new
          enricher.add_fields([:location])
          enricher.fields.should == [:actor, :object, :target, :location]
        end

        describe 'as an empty list does not fail' do
          enricher = StreamRails::Enrich.new
          enricher.add_fields
          enricher.fields.should == [:actor, :object, :target]
        end

        describe 'allowing for subreferences' do
          enricher = StreamRails::Enrich.new
          enricher.add_fields([location: [:tweet]])
          enricher.fields.should == [:actor, :object, :target, location: [:tweet]]
        end
      end
    end
  end

  describe '.enrich_activities' do
    it 'no activities' do
      @enricher.enrich_activities([]).should eq []
    end

    describe 'one activity enriches' do
      it 'without sub-references' do
        instance = create_article
        activity = instance.create_activity
        enriched_activity = @enricher.enrich_activities([activity])[0]
        enriched_activity[:object].should eq instance
        enriched_activity[:actor].should eq @tom
        enriched_activity[:location].should eq @denver
        enriched_activity[:location].name.should eq 'Denver, CO'

        enriched_activity.enriched?.should eq true
        enriched_activity.not_enriched_fields.should eq []
      end
      it 'with sub-references' do
        instance = create_article_subref
        activity = instance.create_activity
        enriched_activity = @enricher_subref.enrich_activities([activity])[0]
        enriched_activity[:actor].should eq @jane
        enriched_activity.enriched?.should eq true
        enriched_activity[:actor].employee.should eq @employee2
      end
    end

    it 'non model object field' do
      instance = create_article
      activity = instance.create_activity
      activity[:object] = 'Planet:42'
      enriched_activity = @enricher.enrich_activities([activity])[0]
      enriched_activity[:object].should eq 'Planet:42'
      enriched_activity[:actor].should eq @tom
      enriched_activity[:location].should eq @denver
      enriched_activity.enriched?.should eq true
    end

    it 'missing model object field' do
      instance = create_article
      activity = instance.create_activity
      activity[:object] = 'User:42'
      enriched_activity = @enricher.enrich_activities([activity])[0]
      enriched_activity[:object].should eq 'User:42'
      enriched_activity[:actor].should eq @tom
      enriched_activity.not_enriched_fields.should eq [:object]
      enriched_activity.enriched?.should eq false
    end

    it 'has target field' do
      instance = create_article
      activity = instance.create_activity
      activity[:target] = 'Planet:42'
      enriched_activity = @enricher.enrich_activities([activity])[0]
      enriched_activity[:target].should eq 'Planet:42'
      enriched_activity.enriched?.should eq true
      enriched_activity.not_enriched_fields.should eq []
    end

    describe 'two activity enriches' do
      it 'without subref lookups' do
        a1 = create_article
        a2 = create_article
        activities = [a1, a2].map(&:create_activity)
        enriched_activities = @enricher.enrich_activities(activities)
        enriched_activities[0][:object].should eq a1
        enriched_activities[1][:object].should eq a2
        enriched_activities[0].enriched?.should eq true
        enriched_activities[1].enriched?.should eq true
        enriched_activities[0].not_enriched_fields.should eq []
        enriched_activities[1].not_enriched_fields.should eq []
      end
      it 'without subref lookups' do
        a1 = create_article_subref
        a2 = create_article_subref(2)
        activities = [a1, a2].map(&:create_activity)
        enriched_activities = @enricher.enrich_activities(activities)
        enriched_activities[0][:object].should eq a1
        enriched_activities[1][:object].should eq a2
        enriched_activities[0].enriched?.should eq true
        enriched_activities[1].enriched?.should eq true
        enriched_activities[0].not_enriched_fields.should eq []
        enriched_activities[1].not_enriched_fields.should eq []

        enriched_activities[0][:actor].should eq @jane
        enriched_activities[0][:actor].employee.should eq @employee2
        enriched_activities[1][:actor].should eq @tom
        enriched_activities[1][:actor].employee.should eq @employee1

      end
    end

    it 'aggregated activity' do
      agg1 = { 'activities' => Array.new(3) { create_article.create_activity } }
      agg2 = { 'activities' => Array.new(5) { create_article.create_activity } }
      agg3 = { 'activities' => Array.new(2) { create_article.create_activity } }
      enriched = @enricher.enrich_aggregated_activities([agg1, agg2, agg3])
      enriched[0]['activities'].length.should eq agg1['activities'].length
      enriched[1]['activities'].length.should eq agg2['activities'].length
      enriched[2]['activities'].length.should eq agg3['activities'].length
    end

    it 'enrich partially missing fields' do
      a1 = create_article
      a2 = create_article
      custom_enricher = StreamRails::Enrich.new([:missing])
      activities = [a1, a2].map(&:create_activity)
      activities[0][:missing] = StreamRails.create_reference(@tom)
      activities[1][:missing] = nil
      enriched = custom_enricher.enrich_activities(activities)
      enriched[0][:missing].should eq @tom
      enriched[1][:missing].should eq nil
    end
  end
end
