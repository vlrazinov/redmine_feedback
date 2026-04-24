class AddVoteFieldsToFeedbacks < ActiveRecord::Migration[5.2]
  def change
    add_column :feedbacks, :vote, :integer
    add_column :feedbacks, :vote_comment, :text
  end
end
