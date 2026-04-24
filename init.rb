require 'redmine'

# Регистрируем макрос
Redmine::WikiFormatting::Macros.register do
  desc "Inserts a link to the feedback form. Usage: {{feedback_link}}"
  macro :feedback_link do |obj, args|
    issue = nil
    
    if obj.is_a?(Issue)
      issue = obj
    elsif obj.is_a?(Journal)
      issue = obj.issue if obj.issue.is_a?(Issue)
      issue ||= obj.journalized if obj.journalized.is_a?(Issue)
    elsif obj.respond_to?(:issue) && obj.issue.is_a?(Issue)
      issue = obj.issue
    end
    
    if issue && issue.is_a?(Issue)
      token = Digest::SHA1.hexdigest("#{issue.id}-#{issue.created_on}-#{Redmine::Configuration['secret_token']}")
      url = "#{Setting.protocol}://#{Setting.host_name}/feedback/#{issue.id}/vote?token=#{token}"
      link_text = Setting.plugin_redmine_feedback['feedback_link_text'] || 'Оценить поддержку'
      "<a href='#{url}' class='feedback-link' target='_blank'>#{link_text}</a>".html_safe
    else
      "Ссылка для оценки доступна только в задачах"
    end
  end
end

Redmine::Plugin.register :redmine_feedback do
  name 'Redmine Feedback plugin'
  author 'Vladislav Razinov'
  description 'Adds universal feedback/voting mechanism for any issue type.'
  version '1.0.1'
  
  permission :view_feedback, { :feedback => [:vote] }, :public => true
  permission :submit_feedback, { :feedback => [:submit] }, :public => true

  settings :default => { 
    'feedback_custom_field_id' => nil,
    'feedback_comment_custom_field_id' => nil,
    'feedback_link_text' => 'Оценить поддержку'
  }, :partial => 'settings/feedback_settings'
  
  # Хук после загрузки плагина - создаём и привязываем поля автоматически
  Redmine::Plugin.after_initialize do
    ensure_feedback_field!
    ensure_feedback_comment_field!
  end
  
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

# Загружаем хук после регистрации плагина
Rails.configuration.to_prepare do
  require_dependency 'redmine_feedback/hooks'
end
