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

    custom_field_id = Setting.plugin_redmine_feedback['feedback_custom_field_id']
    if custom_field_id.present?
      @existing_feedback = @issue.custom_value_for(custom_field_id)&.value
    end
    @feedback = Feedback.find_by(issue_id: @issue.id)
    @existing_comment = @feedback&.vote_comment
    @existing_vote = @feedback&.vote
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
                  when 'good' then 'Хорошо'
                  when 'okay' then 'Нормально'
                  when 'bad' then 'Плохо'
                  else rating
                  end

    custom_field_id = Setting.plugin_redmine_feedback['feedback_custom_field_id']
    if custom_field_id.present? && rating.present?
      custom_value = @issue.custom_values.detect { |v| v.custom_field_id == custom_field_id.to_i }
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

    # Сохраняем голос и комментарий через модель Feedback
    feedback = Feedback.find_or_initialize_by(issue_id: @issue.id)

    # Преобразуем rating в числовое значение vote
    vote_value = case rating
                 when 'good' then Feedback::VOTE_AWESOME
                 when 'okay' then Feedback::VOTE_JUSTOK
                 when 'bad' then Feedback::VOTE_NOTGOOD
                 else nil
                 end

    feedback.update_vote!(vote_value, comment.present? ? comment : nil)

    flash[:notice] = 'Спасибо! Ваша оценка сохранена.'
    redirect_to feedback_vote_path(@issue.id, token: token)
  end
end
