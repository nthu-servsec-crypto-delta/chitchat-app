# frozen_string_literal: true

module ChitChat
  # Postit
  class Postit
    attr_reader :id, :location, :message

    def initialize(postit_data)
      @id = postit_data['id']
      @location = postit_data['location']
      @message = postit_data['message']
    end
  end
end
