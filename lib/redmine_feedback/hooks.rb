module RedmineFeedback
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context)
      stylesheet_link_tag('feedback', :plugin => 'redmine_feedback')
    end
    
    def view_issues_show_details_bottom(context = {})
      issue = context[:issue]
      return '' unless issue
      
      feedback_field_id = Setting.plugin_redmine_feedback['feedback_custom_field_id']
      return '' unless feedback_field_id
      
      custom_value = issue.custom_value_for(feedback_field_id)
      rating = custom_value&.value
      return '' unless rating.present?
      
      rating_text = case rating
                    when 'good' then 'Хорошо'
                    when 'okay' then 'Нормально'
                    when 'bad' then 'Плохо'
                    else rating
                    end
      
      # Получаем комментарий из модели Feedback
      feedback = nil
      begin
        require_dependency 'feedback'
        feedback = Feedback.find_by(issue_id: issue.id)
      rescue => e
        # Игнорируем ошибки загрузки модели
      end
      
      comment = feedback&.comment
      # Формируем tooltip с комментарием
      if comment.present?
        # Очищаем комментарий от переносов строк и экранируем спецсимволы для HTML атрибута
        tooltip_text = comment.to_s.gsub("\n", ' ').gsub("\r", ' ').gsub('"', '&quot;').gsub("'", '&#39;')
        tooltip = "Комментарий: #{tooltip_text}"
        title_attr = "title=\"#{tooltip}\""
      else
        title_attr = ""
      end
      
      html = <<-HTML
        <div class="feedback-info" style="margin-top: 10px;">
          <strong>⭐ Оценка поддержки:</strong>
          <span class="feedback-rating feedback-#{rating}" style="cursor: help; text-decoration: underline dotted;" #{title_attr}>
            #{rating_text}
          </span>
        </div>
      HTML
      
      html.html_safe
    end
  end
end
