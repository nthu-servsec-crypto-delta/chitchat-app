# frozen_string_literal: true

module ChitChat
  # Event Participant
  class EventParticipant
    attr_reader :username, :email

    def initialize(account_data)
      @username = account_data['username']
      @email = account_data['email']
    end
  end
end
