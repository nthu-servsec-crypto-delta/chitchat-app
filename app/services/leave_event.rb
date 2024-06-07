# frozen_string_literal: true

module ChitChat
  # Service object to apply for an event
  class LeaveEvent
    class ForbiddenError < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(current_account, event_id)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .delete("#{@config.API_URL}/events/#{event_id}/participants",
                             json: { email: current_account.account_info['email'] })

      raise ForbiddenError, response.parse['message'] unless response.code == 200

      response.parse
    end
  end
end
