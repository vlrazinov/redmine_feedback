class AddFeedbackCustomField < ActiveRecord::Migration[6.0]
  def up
    field = IssueCustomField.create!(
      name: 'Оценка поддержки', # Название на русском
      field_format: 'string',
      is_for_all: true,
      is_filter: true, # Делаем поле доступным для фильтрации
      editable: true,
      visible: true,
      trackers: Tracker.all # Применяем ко всем трекерам (по умолчанию)
    )

    # Сохраняем ID этого поля в настройках плагина для удобства
    Setting.plugin_redmine_feedback = {} unless Setting.plugin_redmine_feedback
    Setting.plugin_redmine_feedback['feedback_custom_field_id'] = field.id
  end

  def down
    # Удаляем поле и настройки плагина
    field_id = Setting.plugin_redmine_feedback['feedback_custom_field_id']
    IssueCustomField.find_by(id: field_id)&.destroy
    Setting.plugin_redmine_feedback = Setting.plugin_redmine_feedback.merge('feedback_custom_field_id' => nil)
  end
end
