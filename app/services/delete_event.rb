# frozen_string_literal: true

module ChitChat
  # Delete event
  class DeleteEvent
    class ForbiddenError < StandardError; end
    class InvalidRequestError < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(current_account, event_id)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .delete("#{@config.API_URL}/events/#{event_id}")

      raise ForbiddenError, response.parse['message'] if response.code == 403
      raise InvalidRequestError, response.parse['message'] if response.code != 200
    end
  end
end
