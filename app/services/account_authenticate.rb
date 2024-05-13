# frozen_string_literal: true

require 'http'
require 'json'

module ChitChat
  # Service to authenticate an account
  class AccountAuthenticate
    class UnauthorizedError < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(username:, password:)
      response = HTTP.post("#{@config.API_URL}/auth/authenticate", json: { username:, password: })

      raise UnauthorizedError unless response.code == 200

      response.parse
    end
  end
end
