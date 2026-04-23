class Feedback < ApplicationRecord
  belongs_to :issue
  validates :issue_id, presence: true
  
  # Vote constants
  VOTE_NOTGOOD = 0
  VOTE_JUSTOK = 1
  VOTE_AWESOME = 2
  
  # Виртуальное поле для получения значения оценки из кастомного поля задачи
  def rating_value
    custom_field_id = Setting.plugin_redmine_feedback['feedback_custom_field_id']
    if custom_field_id.present? && issue.present?
      issue.custom_value_for(custom_field_id)&.value
    end
  end
  
  # Возвращает текстовое представление голоса
  def vote_text
    case vote
    when VOTE_AWESOME
      I18n.t(:label_good)
    when VOTE_JUSTOK
      I18n.t(:label_okay)
    when VOTE_NOTGOOD
      I18n.t(:label_bad)
    else
      nil
    end
  end
  
  # Обновление голоса с комментарием
  def update_vote!(new_vote, comment = nil)
    old_vote = vote
    old_vote_comment = vote_comment
    
    return unless update vote: new_vote, vote_comment: comment
    return if old_vote == vote && old_vote_comment == vote_comment
    
    # Создаем запись в журнале задачи
    journal = Journal.new journalized: issue, user: User.current
    if old_vote != vote
      journal.details << JournalDetail.new(property: 'attr',
                                           prop_key: 'vote',
                                           old_value: old_vote,
                                           value: vote)
    end
    if old_vote_comment != vote_comment
      journal.details << JournalDetail.new(property: 'attr',
                                           prop_key: 'vote_comment',
                                           old_value: old_vote_comment,
                                           value: vote_comment)
    end
    journal.save!
  end
end
