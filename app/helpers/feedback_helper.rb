module FeedbackHelper
  def rating_text_for(value)
    case value
    when 'Хорошо', 'good' then 'Хорошо'
    when 'Нормально', 'okay' then 'Нормально'
    when 'Плохо', 'bad' then 'Плохо'
    else value.to_s
    end
  end

  # Форматирует значение оценки, добавляя комментарий в title (всплывающую подсказку)
  # Возвращает HTML с подчеркнутым текстом и tooltip при наличии комментария
  def format_feedback_with_tooltip(issue)
    custom_field_id = Setting.plugin_redmine_feedback['feedback_custom_field_id']
    
    return '-' unless custom_field_id.present?

    # Получаем значение оценки из кастомного поля
    rating_value = issue.custom_value_for(custom_field_id)&.value
    
    return '-' unless rating_value.present?

    # Получаем комментарий из таблицы feedbacks
    feedback = Feedback.find_by(issue_id: issue.id)
    comment = feedback&.comment

    text = rating_text_for(rating_value)
    
    if comment.present?
      content_tag(:span, text, 
                  title: comment, 
                  style: "text-decoration: underline dotted; cursor: help; border-bottom: 1px dotted #999;")
    else
      text
    end
  end
end
