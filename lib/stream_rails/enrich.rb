require 'active_record'

module StreamRails

  class ActivityResult < Hash
    attr_accessor :enriched
    attr_reader :failed_to_enrich

    def initialize
      @failed_to_enrich = Hash.new
      super
    end

    def from_activity(h)
      self.merge(h)
    end

    def enriched?
      @failed_to_enrich.keys.length == 0
    end

    def not_enriched_fields
      @failed_to_enrich.keys
    end

    def track_not_enriched_field(field, value = nil)
      @failed_to_enrich[field] = value
    end

  end

  class Enrich

    def initialize(fields = nil)
        @fields = fields || [:actor, :object]
    end

    def model_field?(field_value)
      bits = field_value.split(':')
      if bits.length < 2
        return false
      end
      begin
        bits[0].classify.constantize
      rescue NameError
        return false
      else
        return true
      end
    end

    def enrich_activities(activities)
      references = self.collect_references(activities)
      objects = self.retrieve_objects(references)
      self.inject_objects(activities, objects)
    end

    def enrich_aggregated_activities(aggregated_activities)
      references = Hash.new
      aggregated_activities.each do |aggregated|
        refs = self.collect_references(aggregated['activities'])
        references = references.merge(refs){|key, v1, v2| v1.merge(v2)}
      end
      objects = self.retrieve_objects(references)
      aggregated_activities.each do |aggregated|
        aggregated['activities'] = self.inject_objects(aggregated['activities'], objects)
      end
      aggregated_activities.map {|a| ActivityResult.new().from_activity(a)}
    end

    def collect_references(activities)
      model_refs = Hash.new{ |h,k| h[k] = Hash.new}
      activities.each do |activity|
        activity.select{|k,v| @fields.include? k.to_sym}.each do |field, value|
          next unless self.model_field?(value)
          model, id = value.split(':')
          model_refs[model][id] = 0
        end
      end
      model_refs
    end

    def retrieve_objects(references)
      Hash[references.map{ |model, ids| [model, Hash[model.classify.constantize.where(id: ids.keys).map {|i| [i.id.to_s, i]}] ] }]
    end

    def inject_objects(activities, objects)
      activities = activities.map {|a| ActivityResult.new().from_activity(a)}
      activities.each do |activity|
        activity.select{|k,v| @fields.include? k.to_sym}.each do |field, value|
          next unless self.model_field?(value)
          model, id = value.split(':')
          activity[field] = objects[model][id] || value
          if objects[model][id].nil?
            activity.track_not_enriched_field(field, value)
          end
        end
      end
      activities
    end

  end

end
