# redmine_feedback/db/migrate/001_create_feedbacks.rb

class CreateFeedbacks < ActiveRecord::Migration[6.1]
  def change
    create_table :feedbacks do |t|
      t.references :issue, null: false, foreign_key: true, index: true
      t.text :comment
      t.timestamps
    end
  end
end
