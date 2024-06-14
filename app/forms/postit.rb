# frozen_string_literal: true

require_relative 'form_common'

module ChitChat
  module Form
    # Form validation for create postit
    class Postit < AppContract
      params do
        optional(:message).filled(:string)
        required(:longitude).filled(:float, gt?: -180, lt?: 180)
        required(:latitude).filled(:float, gt?: -180, lt?: 180)
      end
    end
  end
end
