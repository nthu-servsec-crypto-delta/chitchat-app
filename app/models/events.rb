# frozen_string_literal: true

require_relative 'event'

module ChitChat
  # Postits
  class Events
    attr_reader :all

    def initialize(events_data)
      @all = to_events(events_data)
    end

    private

    def to_events(events_data)
      events_data.map do |event_data|
        Event.new(event_data['attributes'])
      end
    end
  end
end
