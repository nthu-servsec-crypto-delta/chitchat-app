# frozen_string_literal: true

require 'roda'

module ChitChat
  # ChitChat App
  class App < Roda
    route('events') do |routing|
      routing.on do
        routing.is do
          # GET /events/
          routing.get do
            if @current_account.logged_in?
              events_response = GetAccountEvents.new(App.config).call(@current_account)
              events = Events.new(events_response).all

              view :events_list, locals: { events: }
            else
              flash[:notice] = 'Please login'
              routing.redirect '/auth/login'
            end
          end
        end

        routing.get String do |event_id|
          event_response = GetEventDetail.new(App.config).call(@current_account, event_id)
          event_data = JSON.parse(event_response['data'])['attributes']
          policies_data = JSON.parse(event_response['policies'])
          policy = PolicySummary.new(policies_data)

          event = Event.new(event_data)

          view :event_detail, locals: { event:, policy: }
        end
      end
    end
  end
end
