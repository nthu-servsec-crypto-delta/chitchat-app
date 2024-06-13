# frozen_string_literal: true

require 'dry-validation'

module ChitChat
  # Form helpers
  module Form
    class ValidationError < StandardError; end

    USERNAME_REGEX = /^[a-zA-Z0-9]+([._]?[a-zA-Z0-9]+)*$/
    EMAIL_REGEX = /@/

    def self.validation_errors(validation)
      validation.errors.to_h.map { |k, v| [k, v].join(' ') }.join('; ')
    end

    def self.message_values(validation)
      validation.errors.to_h.values.join('; ')
    end
  end
end
