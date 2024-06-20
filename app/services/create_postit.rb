# frozen_string_literal: true

module ChitChat
  # Service object to create postit
  class CreatePostit
    class ValidationError < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(current_account, postit_data, event_id)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .post("#{@config.API_URL}/events/#{event_id}/postits",
                           json: postit_data)

      raise ValidationError, response.parse['message'] unless response.code == 201

      response.parse
    end
  end
end
