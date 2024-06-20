# frozen_string_literal: true

module ChitChat
  # Service object to update account location
  class UpdateAccountLocation
    class ApiError < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(current_account, latitude, longitude, event_id) # rubocop:disable Metrics/AbcSize
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .put("#{@config.API_URL}/accounts/#{current_account.username}/location", {
                            json: { latitude:, longitude: }
                          })

      raise ApiError, response.parse['message'] unless response.code == 200

      # get accounts locations of event
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .get("#{@config.API_URL}/events/#{event_id}/accounts")

      raise ApiError, 'Cannot get accounts locations' unless response.code == 200

      response.parse['data']
    end
  end
end
