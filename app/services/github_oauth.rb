# frozen_string_literal: true

require 'http'
require 'json'

module ChitChat
  # Service to authenticate an account that uses GitHub OAuth
  class GitHubOAuthAccount
    class UnauthorizedError < StandardError; end
    class ApiServerError < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(code) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      signed_sso_code = { code: }.then { |sso_code| SignedMessage.sign(sso_code) }
      response = HTTP.post(
        "#{@config.API_URL}/auth/sso/github",
        json: signed_sso_code
      )

      raise UnauthorizedError, response.parse['message'] if response.code == 403
      raise ApiServerError unless response.code == 200

      account_info = response.parse['attributes']

      { account: account_info['account']['attributes'],
        auth_token: account_info['auth_token'] }
    rescue HTTP::ConnectionError
      raise ApiServerError
    end
  end
end
