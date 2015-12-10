# Provides a shortcut from views to the rendering method.
module StreamRails
  # Module extending ActionView::Base and adding `render_activity` helper.
  module ViewHelpers
    # View helper for rendering an activity
    def render_activity(activity, options = {})
      Renderable.render(activity, self, options)
    end

    # View helper for rendering many activities
    def render_activities(activities, options = {})
      activities.map { |activity| Renderable.render(activity, self, options.dup) }.join.html_safe
    end
  end
  ActionView::Base.class_eval { include ViewHelpers }
end
