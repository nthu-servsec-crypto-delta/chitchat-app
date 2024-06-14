# frozen_string_literal: true

require_relative 'form_common'

module ChitChat
  module Form
    # Form validation for create postit
    class Postit < AppContract
      config.messages.load_paths << File.join(__dir__, 'errors/location.yml')

      params do
        optional(:message).filled(:str?)
        required(:longitude).filled(:str?) # TODO: fix type: float
        required(:latitude).filled(:str?)
      end
    end
  end
end
