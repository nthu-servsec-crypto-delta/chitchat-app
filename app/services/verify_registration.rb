# frozen_string_literal: true

require 'http'
require 'json'

require_relative '../lib/secure_message'

module ChitChat
  # Service for registration with email verification
  class VerifyRegistration
    class InvalidRegistrationError < StandardError; end
    class ApiServerError < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(registration_data)
      registration_token = SecureMessage.encrypt(registration_data)
      registration_data[:verification_url] = "#{App.config.APP_URL}/auth/register/#{registration_token}"

      res = HTTP.post(
        "#{@config.API_URL}/auth/register",
        json: SignedMessage.sign(registration_data)
      )

      data = res.parse
      raise InvalidRegistrationError, data['message'] unless res.status.success?
    rescue HTTP::Error
      raise ApiServerError
    end
  end
end
