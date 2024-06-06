# frozen_string_literal: true

require 'http'

module ChitChat
  # Get event that the account participated
  class GetEventDetail
    def initialize(config)
      @config = config
    end

    def call(current_account, event_id)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .get("#{@config.API_URL}/events/#{event_id}")

      response.code == 200 ? response.parse['attributes'] : nil
    end
  end
end
