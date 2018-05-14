require 'active_record'

module StreamRails
  class ActivityResult < Hash
    attr_accessor :enriched
    attr_reader :failed_to_enrich

    def initialize
      @failed_to_enrich = {}
      super
    end

    def from_activity(h)
      merge(h)
    end

    def enriched?
      @failed_to_enrich.keys.length.zero?
    end

    def not_enriched_fields
      @failed_to_enrich.keys
    end

    def track_not_enriched_field(field, value = nil)
      @failed_to_enrich[field] = value
    end
  end

  class Enrich
    attr_reader :fields

    def initialize(fields = nil)
      @fields = fields || [:actor, :object, :target]
    end

    def add_fields(new_fields)
      new_fields.each { |i| @fields << i }
    end

    def model_field?(field_value)
      return false unless field_value.respond_to?('split')
      bits = field_value.split(':')
      return false if bits.length < 2
      begin
        bits[0].classify.constantize
      rescue NameError
        return false
      else
        return true
      end
    end

    def enrich_activities(activities, options = {})
      references = collect_references(activities)
      objects = retrieve_objects(references, options[:includes])
      inject_objects(activities, objects)
    end

    def enrich_aggregated_activities(aggregated_activities)
      references = {}
      aggregated_activities.each do |aggregated|
        refs = collect_references(aggregated['activities'])
        references = references.merge(refs) { |_key, v1, v2| v1.merge(v2) }
      end
      objects = retrieve_objects(references)
      aggregated_activities.each do |aggregated|
        aggregated['activities'] = inject_objects(aggregated['activities'], objects)
      end
      create_activity_results(aggregated_activities)
    end

    def collect_references(activities)
      model_refs = Hash.new { |h, k| h[k] = {} }
      activities.each do |activity|
        activity.select { |k, _v| @fields.include? k.to_sym }.each do |_field, value|
          next unless model_field?(value)
          model, id = value.split(':')
          model_refs[model][id] = 0
        end
      end
      model_refs
    end

    def retrieve_objects(references, includes = nil)
      Hash[references.map { |model, ids|
        scope = model.classify.constantize.where(id: ids.keys)
        scope = scope.includes(includes[model]) if includes[model].present?
        mapped_ids = scope.map { |i| [i.id.to_s, i] }
        [model, Hash[mapped_ids]] }]
    end

    def inject_objects(activities, objects)
      create_activity_results(activities).each do |activity|
        activity.select { |k, _v| @fields.include? k.to_sym }.each do |field, value|
          next unless model_field?(value)
          model, id = value.split(':')
          activity[field] = objects[model][id] || value
          activity.track_not_enriched_field(field, value) if objects[model][id].nil?
        end
      end
    end

    private

    def create_activity_results(activities)
      return activities.map { |a| ActivityResult.new.from_activity(a) }
    end
  end
end
