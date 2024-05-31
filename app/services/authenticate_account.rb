# frozen_string_literal: true

require 'http'
require 'json'

module ChitChat
  # Service to authenticate an account
  class AuthenticateAccount
    class UnauthorizedError < StandardError; end
    class ApiServerError < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(username:, password:)
      response = HTTP.post("#{@config.API_URL}/auth/authenticate", json: { username:, password: })

      raise UnauthorizedError if response.code == 403
      raise ApiServerError unless response.code == 200

      account_info = JSON.parse(response.to_s)['attributes']

      { account: account_info['account']['attributes'],
        auth_token: account_info['auth_token'] }
    rescue HTTP::ConnectionError
      raise ApiServerError
    end
  end
end
