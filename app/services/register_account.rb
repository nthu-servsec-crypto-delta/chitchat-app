# frozen_string_literal: true

require 'http'
require 'json'

module ChitChat
  # Service to register an account
  class AccountAuthenticate
    class InvalidAccount < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(email:, username:, password:)
      response = HTTP.post("#{@config.API_URL}/accounts", json: { email:, username:, password: })

      raise InvalidAccount unless response.code == 201
    end
  end
end
