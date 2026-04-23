class Feedback < ApplicationRecord
  belongs_to :issue
  validates :issue_id, presence: true
  
  # Виртуальное поле для получения значения оценки из кастомного поля задачи
  def rating_value
    custom_field_id = Setting.plugin_redmine_feedback['feedback_custom_field_id']
    if custom_field_id.present? && issue.present?
      issue.custom_value_for(custom_field_id)&.value
    end
  end
end
