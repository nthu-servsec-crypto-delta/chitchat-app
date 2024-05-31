# frozen_string_literal: true

require 'http'

module ChitChat
  # Get all postits
  class GetAllPostits
    def initialize(config)
      @config = config
    end

    def call(current_account)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .get("#{@config.API_URL}/postits")

      response.code == 200 ? response.parse['data'] : nil
    end
  end
end
