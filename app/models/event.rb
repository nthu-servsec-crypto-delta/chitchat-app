# frozen_string_literal: true

module ChitChat
  # Event
  class Event
    attr_reader :id, :name, :description, :location, :radius, :start_time, :end_time,
                :organizer, :co_organizers, :participants

    def initialize(event_data) # rubocop:disable Metrics/AbcSize
      @id = event_data['id']
      @name = event_data['name']
      @description = event_data['description']
      @location = event_data['location']
      @radius = event_data['radius']
      @start_time = event_data['start_time']
      @end_time = event_data['end_time']
      @organizer = event_data['organizer'].nil? ? nil : EventParticipant.new(event_data['organizer']['attributes'])
      @co_organizers = event_data['co_organizers'].map { |data| EventParticipant.new(data['attributes']) }
      @participants = event_data['participants'].map { |data| EventParticipant.new(data['attributes']) }
    end
  end
end
