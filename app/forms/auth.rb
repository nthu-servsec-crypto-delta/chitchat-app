# frozen_string_literal: true

require_relative 'form_common'

module ChitChat
  module Form
    # Form validation for authentication
    class LoginCredentials < Dry::Validation::Contract
      params do
        required(:username).filled
        required(:password).filled
      end
    end

    # Form validation for registration
    class Registration < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/account_details.yml')

      params do
        required(:username).filled(format?: USERNAME_REGEX, min_size?: 4)
        required(:email).filled(format?: EMAIL_REGEX)
      end
    end

    # Form validation for set password
    class Passwords < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/password.yml')

      params do
        required(:password).filled
        required(:repeat_password).filled
      end

      def enough_entropy?(string)
        StringSecurity.entropy(string) >= 3.0
      end

      rule(:password) do
        key.failure(:entropy) unless enough_entropy?(value)
      end

      rule(:password, :repeat_password) do
        key.failure(:match) unless values[:password].eql?(values[:repeat_password])
      end
    end
  end
end
