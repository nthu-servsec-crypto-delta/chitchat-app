# frozen_string_literal: true

module ChitChat
  # Create event
  class CreateEvent
    class ForbiddenError < StandardError; end
    class InvalidRequestError < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(current_account, event_data) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .post("#{@config.API_URL}/events",
                           json: {
                             name: event_data['name'],
                             description: event_data['description'],
                             location: { latitude: event_data['latitude'], longitude: event_data['longitude'] },
                             radius: event_data['radius'],
                             start_time: event_data['start_time'],
                             end_time: event_data['end_time']
                           })

      raise ForbiddenError, response.parse['message'] if response.code == 403
      raise InvalidRequestError, response.parse['message'] if response.code == 400 || response.code == 500

      response.code == 201 ? response.parse['id'] : nil
    end
  end
end
