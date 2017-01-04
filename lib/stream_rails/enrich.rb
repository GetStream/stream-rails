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
    attr_reader :fields, :subreferences

    def initialize(fields = nil)
      @fields = [:actor, :object, :target]
      if fields
        fields.each { |i| @fields << i }
      end
    end

    def add_fields(new_fields = nil)
      if new_fields
        new_fields.each { |i| @fields << i }
      end
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

    def enrich_activities(activities)
      references = collect_references(activities)
      objects = retrieve_objects(references)
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
        check_fields = []
        @fields.each do |field|
          if !field.is_a?(Hash)
            check_fields << field
          else
            check_fields << field.keys
          end
          activity.select { |k, _v| check_fields.include? k.to_sym }.each do |_field, value|
            next unless model_field?(value)
            model, id = value.split(':')
            model_refs[model][id] = 0
          end
        end
      end
      model_refs
    end

    def retrieve_objects2(references)
      foo = Hash[references.map { |model, ids| [model, Hash[model.classify.constantize.where(id: ids.keys).map { |i| [i.id.to_s, i] }]] }]
      $stderr.puts foo
      foo
    end

    def retrieve_objects(references)
      objects = Hash.new
        references.map do |model, ids|
          sub_refs = []
          @fields.each do |tmp|
            if tmp.is_a? Hash
              sub_refs = tmp[model.to_sym]
            end
          end
          if sub_refs.length > 0
            $stderr.puts "subref lookup on tmp:#{tmp}, model:#{model} includes:#{tmp[model.to_sym]}"
            objects[model] = Hash[model.classify.constantize.where(id: ids.keys).includes(tmp[model.to_sym]).map { |i| [i.id.to_s, i] }]
          else
            objects[model] = Hash[model.classify.constantize.where(id: ids.keys).map { |i| [i.id.to_s, i] }]
          end
        end
      $stderr.puts "objects: #{objects}"
      $stderr.puts '------------'
      objects
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
