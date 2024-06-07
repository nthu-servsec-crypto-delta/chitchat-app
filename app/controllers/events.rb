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

        # GET /events/[event_id]
        routing.on String do |event_id| # rubocop:disable Lint/BlockLength
          routing.get do
            event_response = GetEventDetail.new(App.config).call(@current_account, event_id)
            event_data = event_response['attributes']
            policies_data = event_response['policies']
            policy = PolicySummary.new(policies_data)

            event = Event.new(event_data)

            view :event_detail, locals: { event:, policy: }
          end

          routing.on 'participant' do # rubocop:disable Lint/BlockLength
            # POST /events/[event_id]/participant
            routing.post do # rubocop:disable Lint/BlockLength
              if @current_account.logged_in?
                redirect_to_event = true

                case routing.params['action']
                when 'apply'
                  ApplyEvent.new(App.config).call(@current_account, event_id)
                  flash[:notice] = 'You have successfully applied for the event'
                when 'leave'
                  LeaveEvent.new(App.config).call(@current_account, event_id)
                  flash[:notice] = 'You have successfully left the event'
                  redirect_to_event = false
                when 'cancel'
                  CancelEventApplication.new(App.config).call(@current_account, event_id)
                  flash[:notice] = 'You have successfully cancelled your application to the event'
                else
                  flash[:error] = 'Invalid action'
                end

                if redirect_to_event
                  routing.redirect "/events/#{event_id}"
                else
                  routing.redirect '/events'
                end
              else
                flash[:notice] = 'Please login'
                routing.redirect '/auth/login'
              end
            rescue ApplyEvent::ForbiddenError, LeaveEvent::ForbiddenError,
                   CancelEventApplication::ForbiddenError => e
              flash[:error] = e.message
              routing.redirect "/events/#{event_id}"
            end
          end
        end
      end
    end
  end
end
