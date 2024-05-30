# frozen_string_literal: true

require 'http'
require 'json'

module ChitChat
  # Service to authenticate an account
  class AccountAuthenticate
    class UnauthorizedError < StandardError; end
    class ApiServerError < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(username:, password:)
      response = HTTP.post("#{@config.API_URL}/auth/authenticate", json: { username:, password: })

      raise UnauthorizedError if response.code == 403
      raise ApiServerError unless response.code == 200

      response.parse['attributes']
    end
  end
end
