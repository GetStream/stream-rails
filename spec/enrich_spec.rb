require 'spec_helper'
require 'spec_database'

describe 'StreamRails::Enrich' do
  before do
    @enricher = StreamRails::Enrich.new
    @tom = User.new
    @tom.save!

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

  describe 'enricher' do
    it 'has default settings for enriched fields' do
      enricher = StreamRails::Enrich.new
      expect(enricher.fields).to eq %i[actor object target]
    end

    it 'can add additional settings for enriched fields' do
      enricher = StreamRails::Enrich.new
      enricher.add_fields([:location])
      expect(enricher.fields).to eq %i[actor object target location]
    end
  end

  describe '.enrich_activities' do
    it 'no activities' do
      expect(@enricher.enrich_activities([])).to eq []
    end

    it 'one activity' do
      instance = create_article
      activity = instance.create_activity
      enriched_activity = @enricher.enrich_activities([activity])[0]
      expect(enriched_activity[:object]).to eq instance
      expect(enriched_activity[:actor]).to eq @tom
      expect(enriched_activity[:location]).to eq @denver
      expect(enriched_activity[:location].name).to eq 'Denver, CO'

      expect(enriched_activity.enriched?).to eq true
      expect(enriched_activity.not_enriched_fields).to eq []
    end

    it 'non model object field' do
      instance = create_article
      activity = instance.create_activity
      activity[:object] = 'Planet:42'
      enriched_activity = @enricher.enrich_activities([activity])[0]
      expect(enriched_activity[:object]).to eq 'Planet:42'
      expect(enriched_activity[:actor]).to eq @tom
      expect(enriched_activity[:location]).to eq @denver
      expect(enriched_activity.enriched?).to eq true
    end

    it 'missing model object field' do
      instance = create_article
      activity = instance.create_activity
      activity[:object] = 'User:42'
      enriched_activity = @enricher.enrich_activities([activity])[0]
      expect(enriched_activity[:object]).to eq 'User:42'
      expect(enriched_activity[:actor]).to eq @tom
      expect(enriched_activity.not_enriched_fields).to eq [:object]
      expect(enriched_activity.enriched?).to eq false
    end

    it 'has target field' do
      instance = create_article
      activity = instance.create_activity
      activity[:target] = 'Planet:42'
      enriched_activity = @enricher.enrich_activities([activity])[0]
      expect(enriched_activity[:target]).to eq 'Planet:42'
      expect(enriched_activity.enriched?).to eq true
      expect(enriched_activity.not_enriched_fields).to eq []
    end

    it 'two activity' do
      a1 = create_article
      a2 = create_article
      activities = [a1, a2].map(&:create_activity)
      enriched_activities = @enricher.enrich_activities(activities)
      expect(enriched_activities[0][:object]).to eq a1
      expect(enriched_activities[1][:object]).to eq a2
      expect(enriched_activities[0].enriched?).to eq true
      expect(enriched_activities[1].enriched?).to eq true
      expect(enriched_activities[0].not_enriched_fields).to eq []
      expect(enriched_activities[1].not_enriched_fields).to eq []
    end

    it 'aggregated activity' do
      agg1 = { 'activities' => Array.new(3) { create_article.create_activity } }
      agg2 = { 'activities' => Array.new(5) { create_article.create_activity } }
      agg3 = { 'activities' => Array.new(2) { create_article.create_activity } }
      enriched = @enricher.enrich_aggregated_activities([agg1, agg2, agg3])
      expect(enriched[0]['activities'].length).to eq agg1['activities'].length
      expect(enriched[1]['activities'].length).to eq agg2['activities'].length
      expect(enriched[2]['activities'].length).to eq agg3['activities'].length
    end

    it 'enrich partially missing fields' do
      a1 = create_article
      a2 = create_article
      custom_enricher = StreamRails::Enrich.new([:missing])
      activities = [a1, a2].map(&:create_activity)
      activities[0][:missing] = StreamRails.create_reference(@tom)
      activities[1][:missing] = nil
      enriched = custom_enricher.enrich_activities(activities)
      expect(enriched[0][:missing]).to eq @tom
      expect(enriched[1][:missing]).to eq nil
    end
  end
end
