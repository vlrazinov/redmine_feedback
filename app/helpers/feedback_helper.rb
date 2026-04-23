module FeedbackHelper
  def rating_text_for(value)
    case value
    when 'Хорошо', 'good' then 'Хорошо'
    when 'Нормально', 'okay' then 'Нормально'
    when 'Плохо', 'bad' then 'Плохо'
    else value.to_s
    end
  end
end
