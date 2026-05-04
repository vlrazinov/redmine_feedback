# redmine_feedback/config/routes.rb

get 'feedback/:id/vote', to: 'feedback#vote', as: 'feedback_vote'
post 'feedback/:id/submit', to: 'feedback#submit', as: 'feedback_submit'
post 'feedback/create_custom_field', to: 'feedback#create_custom_field', as: 'feedback_create_custom_field'
