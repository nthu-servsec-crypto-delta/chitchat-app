# frozen_string_literal: true

require 'http'

module ChitChat
  # Get event that the account participated
  class GetEventDetail
    class NotFoundError < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(current_account, event_id)
      response = if current_account.logged_in?
                   HTTP.auth("Bearer #{current_account.auth_token}").get("#{@config.API_URL}/events/#{event_id}")
                 else
                   HTTP.get("#{@config.API_URL}/events/#{event_id}")
                 end

      raise NotFoundError, 'Event not found' if response.code == 404

      data = response.parse

      response.code == 200 ? [data['attributes'], data['policies']] : nil
    end
  end
end
