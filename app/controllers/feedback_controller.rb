class FeedbackController < ApplicationController
  skip_before_action :check_if_login_required, only: [:vote, :submit]
  layout 'base'
  
  def vote
    @issue = Issue.find_by(id: params[:id])
    token = params[:token]
    
    if @issue.nil?
      render_404
      return
    end
    
    expected_token = Digest::SHA1.hexdigest("#{@issue.id}-#{@issue.created_on}-#{Redmine::Configuration['secret_token']}")
    
    if token != expected_token
      render_404
      return
    end
    
    custom_field_id = get_feedback_custom_field_id
    if custom_field_id.present?
      @existing_feedback = @issue.custom_value_for(custom_field_id)&.value
    end
    @existing_comment = Feedback.find_by(issue_id: @issue.id)&.comment
  end
  
  def submit
    @issue = Issue.find_by(id: params[:id])
    token = params[:token]
    
    expected_token = Digest::SHA1.hexdigest("#{@issue.id}-#{@issue.created_on}-#{Redmine::Configuration['secret_token']}")
    
    if @issue.nil? || token != expected_token
      render_404
      return
    end
    
    rating = params[:rating]
    comment = params[:comment]
    
    # Сохраняем русское название напрямую
    rating_value = case rating
                  when 'good', 'Хорошо' then 'Хорошо'
                  when 'okay', 'Нормально' then 'Нормально'
                  when 'bad', 'Плохо' then 'Плохо'
                  else rating
                  end
    
    custom_field_id = get_feedback_custom_field_id
    if custom_field_id.present? && rating.present?
      custom_value = @issue.custom_values.detect { |v| v.custom_field_id == custom_field_id }
      if custom_value.nil?
        custom_value = CustomValue.new(
          customized: @issue,
          custom_field_id: custom_field_id,
          value: rating_value
        )
        custom_value.save
      else
        custom_value.value = rating_value
        custom_value.save
      end
    end
    
    if comment.present?
      feedback = Feedback.find_or_initialize_by(issue_id: @issue.id)
      feedback.comment = comment
      feedback.save
    end
    
    if comment.present?
      journal = @issue.init_journal(User.anonymous, "")
      journal.notes = "**Комментарий по оценке ТП:**\n\n#{comment}"
      journal.private_notes = true
      journal.save
    end
    
    flash[:notice] = 'Спасибо! Ваша оценка сохранена.'
    redirect_to feedback_vote_path(@issue.id, token: token)
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
