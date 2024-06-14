# frozen_string_literal: true

require_relative 'form_common'

module ChitChat
  module Form
    # Form validation for create/edit event
    class Event < AppContract
      params do
        required(:name).filled(:string)
        optional(:descritpion).filled(:string)
        required(:longitude).filled(:float, gt?: -180, lt?: 180)
        required(:latitude).filled(:float, gt?: -180, lt?: 180)
        required(:radius).filled(:string)
        required(:start_time).filled(:date_time)
        required(:end_time).filled(:date_time)
      end
    end
  end
end
