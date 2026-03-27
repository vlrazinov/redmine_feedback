class AddFeedbackCustomField < ActiveRecord::Migration[6.0]
  def up
    # Ищем существующее поле с таким именем
    field = IssueCustomField.find_by(name: 'Оценка поддержки')
    
    if field.nil?
      # Создаём новое поле, если не найдено
      field = IssueCustomField.create!(
        name: 'Оценка поддержки',
        field_format: 'string',
        is_for_all: true,
        is_filter: true,
        editable: true,
        visible: true,
        trackers: Tracker.all
      )
    end
    
    # Сохраняем ID поля в настройках для совместимости
    Setting.plugin_redmine_feedback = {} unless Setting.plugin_redmine_feedback
    Setting.plugin_redmine_feedback['feedback_custom_field_id'] = field.id
  end

  def down
    # Удаляем только поле, созданное плагином (по имени)
    field = IssueCustomField.find_by(name: 'Оценка поддержки')
    field&.destroy
    # Не удаляем настройки полностью, только сбрасываем ID
    if Setting.plugin_redmine_feedback.is_a?(Hash)
      Setting.plugin_redmine_feedback = Setting.plugin_redmine_feedback.merge('feedback_custom_field_id' => nil)
    end
  end
end
