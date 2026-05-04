class Feedback < ApplicationRecord
  belongs_to :issue
  validates :issue_id, presence: true
end
