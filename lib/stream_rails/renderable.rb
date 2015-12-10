module StreamRails
  # Provides logic for rendering activities. (different templates per activity verb).
  module Renderable
    class << self
      def render(activity, context, params = {})
        aggregated = activity.key? 'activities'
        partial = partial_path(activity, aggregated, *params.values_at(:prefix, :partial, :partial_root))
        layout  = layout_path(*params.values_at(:layout, :layout_root))
        locals  = prepare_locals(activity, params)
        params = params.merge(partial: partial, locals: locals, layout: layout)
        if aggregated
          render_aggregated(activity, context, params)
        else
          render_simple(activity, context, params)
        end
      end

      def render_simple(activity, context, params)
        if activity.enriched?
          context.render params
        else
          StreamRails.logger.warn "trying to display a non enriched activity #{activity.inspect} #{activity.failed_to_enrich}"
          return ''
        end
      end

      def render_aggregated(activity, context, params)
        if !activity['activities'].map { |a| !a.enriched? }.all?
          context.render params
        else
          first_activity = activity['activities'][0]
          StreamRails.logger.warn "trying to display a non enriched activity #{first_activity.inspect} #{first_activity.failed_to_enrich}"
          return ''
        end
      end

      def layout_path(path = nil, root = nil)
        path.nil? && return
        root ||= 'layouts'
        select_path path, root
      end

      def partial_path(activity, aggregated, prefix = '', path = nil, root = nil)
        root ||= (aggregated ? 'aggregated_activity' : 'activity')
        path ||= "#{activity['verb']}".downcase
        path = "#{prefix}_#{path}" if prefix
        select_path path, root
      end

      def prepare_locals(activity, params)
        locals = params.delete(:locals) || {}
        locals.merge\
          activity:     activity,
          parameters:   params
      end

      private

      def select_path(path, root)
        [root, path].map(&:to_s).join('/')
      end
    end
  end
end
