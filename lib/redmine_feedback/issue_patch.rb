# redmine_feedback/lib/redmine_feedback/issue_patch.rb

module RedmineFeedback
  module IssuePatch
    def self.included(base)
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def public_feedback_url
        Rails.application.routes.url_helpers.url_for(
          controller: 'feedback',
          action: 'vote',
          id: self.id,
          token: generate_feedback_token,
          only_path: false,
          host: Setting.host_name
        )
      end

      private

      def generate_feedback_token
        Digest::SHA1.hexdigest("#{self.id}-#{self.created_on}-#{Redmine::Configuration['secret_token']}")
      end
    end
  end
end

module Redmine::WikiFormatting::Macros
  module Definitions
    Redmine::WikiFormatting::Macros.register do
      desc "Inserts a link to the feedback form. Usage: {{feedback_link}} or {{feedback_link_with_text|Your text}}"
      macro :feedback_link do |obj, args|
        if obj.is_a?(Issue)
          link_text = Setting.plugin_redmine_feedback['feedback_link_text'] || l(:label_feedback_link_text)
          url = obj.public_feedback_url
          link = "<a href='#{url}' class='feedback-link' target='_blank'>#{link_text}</a>"
          "<div class='feedback-macro'>#{link}</div>".html_safe
        else
          l(:label_feedback_link_error)
        end
      end
    end
    
    Redmine::WikiFormatting::Macros.register do
      desc "Inserts a link to the feedback form with custom text. Usage: {{feedback_link_with_text|Your text}}"
      macro :feedback_link_with_text do |obj, args|
        if obj.is_a?(Issue) && args.first.present?
          url = obj.public_feedback_url
          link = "<a href='#{url}' class='feedback-link' target='_blank'>#{args.first}</a>"
          "<div class='feedback-macro'>#{link}</div>".html_safe
        else
          l(:label_feedback_link_error)
        end
      end
    end
  end
end
