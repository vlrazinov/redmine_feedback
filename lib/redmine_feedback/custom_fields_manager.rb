module RedmineFeedback
  class CustomFieldsManager
    # Вызывается при инициализации плагина для создания и привязки полей
    def self.ensure_custom_fields_exist!
      ensure_feedback_field!
      ensure_feedback_comment_field!
    end

    private

    def self.ensure_feedback_field!
      field_id = Setting.plugin_redmine_feedback['feedback_custom_field_id']
      
      # Если поле уже настроено, проверяем существует ли оно
      if field_id.present?
        existing_field = IssueCustomField.find_by(id: field_id)
        return if existing_field && existing_field.name == 'Оценка поддержки'
      end
      
      # Ищем поле по имени
      existing_field = IssueCustomField.find_by(name: 'Оценка поддержки')
      if existing_field
        Setting.plugin_redmine_feedback = Setting.plugin_redmine_feedback.merge(
          'feedback_custom_field_id' => existing_field.id.to_s
        )
        return
      end
      
      # Создаём новое поле
      field = IssueCustomField.create!(
        name: 'Оценка поддержки',
        field_format: 'string',
        is_for_all: true,
        is_filter: true,
        editable: true,
        visible: true,
        trackers: Tracker.all
      )
      
      Setting.plugin_redmine_feedback = Setting.plugin_redmine_feedback.merge(
        'feedback_custom_field_id' => field.id.to_s
      )
    rescue => e
      Rails.logger.error "[Redmine Feedback] Error creating feedback custom field: #{e.message}"
    end

    def self.ensure_feedback_comment_field!
      field_id = Setting.plugin_redmine_feedback['feedback_comment_custom_field_id']
      
      # Если поле уже настроено, проверяем существует ли оно
      if field_id.present?
        existing_field = IssueCustomField.find_by(id: field_id)
        return if existing_field && existing_field.name == 'Комментарий к оценке поддержки'
      end
      
      # Ищем поле по имени
      existing_field = IssueCustomField.find_by(name: 'Комментарий к оценке поддержки')
      if existing_field
        Setting.plugin_redmine_feedback = Setting.plugin_redmine_feedback.merge(
          'feedback_comment_custom_field_id' => existing_field.id.to_s
        )
        return
      end
      
      # Создаём новое поле
      field = IssueCustomField.create!(
        name: 'Комментарий к оценке поддержки',
        field_format: 'text',
        is_for_all: true,
        is_filter: true,
        editable: true,
        visible: true,
        trackers: Tracker.all
      )
      
      Setting.plugin_redmine_feedback = Setting.plugin_redmine_feedback.merge(
        'feedback_comment_custom_field_id' => field.id.to_s
      )
    rescue => e
      Rails.logger.error "[Redmine Feedback] Error creating feedback comment custom field: #{e.message}"
    end
  end
end
