# frozen_string_literal: true

module ChitChat
  # Service object to reject event application
  class RejectEventApplication
    class ForbiddenError < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(current_account, event_id, target_account_email)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .delete("#{@config.API_URL}/events/#{event_id}/applicants",
                             json: { email: target_account_email })

      raise ForbiddenError, response.parse['message'] unless response.code == 200

      response.parse
    end
  end
end
