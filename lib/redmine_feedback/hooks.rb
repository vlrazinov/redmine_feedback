module RedmineFeedback
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context)
      stylesheet_link_tag('feedback', :plugin => 'redmine_feedback')
    end
    
    def view_issues_show_details_bottom(context = {})
      issue = context[:issue]
      return '' unless issue
      
      feedback_field_id = get_feedback_custom_field_id
      return '' unless feedback_field_id
      
      custom_value = issue.custom_value_for(feedback_field_id)
      rating = custom_value&.value
      return '' unless rating.present?
      
      rating_text = case rating
                    when 'good', 'Хорошо' then 'Хорошо'
                    when 'okay', 'Нормально' then 'Нормально'
                    when 'bad', 'Плохо' then 'Плохо'
                    else rating
                    end
      
      feedback = Feedback.find_by(issue_id: issue.id)
      comment = feedback&.comment
      tooltip = comment.present? ? "Комментарий: #{comment}" : ''
      
      html = <<-HTML
        <div class="feedback-info" style="margin-top: 10px;">
          <strong>⭐ Оценка поддержки:</strong>
          <span class="feedback-rating feedback-#{rating.to_s.parameterize}" style="cursor: help;" title="#{tooltip}">
            #{rating_text}
          </span>
        </div>
      HTML
      
      html.html_safe
    end
    
    private
    
    # Получает ID поля из настроек или ищет по имени
    def get_feedback_custom_field_id
      field_id = Setting.plugin_redmine_feedback['feedback_custom_field_id']
      
      # Если ID есть в настройках и поле существует - используем его
      if field_id.present? && IssueCustomField.exists?(id: field_id)
        return field_id
      end
      
      # Иначе ищем поле по имени
      field = IssueCustomField.find_by(name: 'Оценка поддержки')
      field&.id
    end
  end
end
