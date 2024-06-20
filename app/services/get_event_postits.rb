# frozen_string_literal: true

require 'http'

module ChitChat
  # Get postits created by account
  class GetEventPostits
    def initialize(config)
      @config = config
    end

    def call(current_account, event_id)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .get("#{@config.API_URL}/events/#{event_id}/postits")

      response.code == 200 ? response.parse['data'] : []
    end
  end
end
