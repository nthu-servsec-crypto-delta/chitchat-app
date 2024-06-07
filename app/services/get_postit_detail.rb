# frozen_string_literal: true

require 'http'

module ChitChat
  # Get postit detail
  class GetPostitDetail
    def initialize(config)
      @config = config
    end

    def call(current_account, postit_id)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .get("#{@config.API_URL}/postits/#{postit_id}")

      response.code == 200 ? response.parse : nil
    end
  end
end
