# frozen_string_literal: true

require_relative 'form_common'

module ChitChat
  module Form
    # Form validation for authentication
    class Event < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/location.yml')
      config.messages.load_paths << File.join(__dir__, 'errors/event.yml')

      params do
        required(:name).filled(:str?)
        optional(:descritpion).filled(:str?)
        required(:longitude).filled(:str?) # TODO: fix type: float
        required(:latitude).filled(:str?)
        required(:radius).filled(:str?)
        required(:start_time).filled(:str?) # TODO: fix type: date_time
        required(:end_time).filled(:str?)
      end
    end
  end
end
