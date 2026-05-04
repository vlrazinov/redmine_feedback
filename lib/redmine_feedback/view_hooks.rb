module RedmineFeedback
  module ViewHooks
    def self.view_issues_show_details_bottom(context = {})
      issue = context[:issue]
      return '' unless issue

      feedback_field_id = Setting.plugin_redmine_feedback['feedback_custom_field_id']
      return '' unless feedback_field_id

      custom_value = issue.custom_value_for(feedback_field_id)
      rating = custom_value&.value
      return '' unless rating.present?

      feedback = Feedback.find_by(issue_id: issue.id)
      comment = feedback&.comment

      rating_text = case rating
                    when 'good' then l(:label_good)
                    when 'okay' then l(:label_okay)
                    when 'bad' then l(:label_bad)
                    else rating
                    end

      tooltip_text = comment.present? ? l(:label_comment) + ': ' + comment : ''

      content_tag(:div, class: 'feedback-info') do
        content_tag(:span, rating_text, class: "feedback-rating feedback-#{rating}", title: tooltip_text)
      end
    end
  end
end
