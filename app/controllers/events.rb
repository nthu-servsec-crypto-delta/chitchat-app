# frozen_string_literal: true

require 'roda'

module ChitChat
  # ChitChat App
  class App < Roda # rubocop:disable Metrics/ClassLength
    route('events') do |routing| # rubocop:disable Metrics/BlockLength
      routing.on do # rubocop:disable Metrics/BlockLength
        routing.on 'all' do
          # GET /events/all
          routing.get do
            if @current_account.logged_in?
              events_response = GetEvents.new(App.config).call(@current_account)
              events = Events.new(events_response).all

              view :events_list, locals: { events: }
            else
              flash[:notice] = 'Please login'
              routing.redirect '/auth/login'
            end
          end
        end

        routing.is do
          # GET /events
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

          # POST /events
          routing.post do
            if @current_account.logged_in?
              event = Form::Event.new.call(routing.params)
              raise Form::ValidationError, Form.validation_errors(event) if event.failure?

              event_id = CreateEvent.new(App.config).call(@current_account, routing.params)
              flash[:success] = 'Event created successfully'
              routing.redirect "/events/#{event_id}"
            else
              flash[:notice] = 'Please login'
              routing.redirect '/auth/login'
            end
          rescue CreateEvent::ForbiddenError, CreateEvent::InvalidRequestError, Form::ValidationError => e
            flash[:error] = e.message
            routing.redirect '/events'
          end
        end

        routing.on String do |event_id| # rubocop:disable Metrics/BlockLength
          @current_event_route = "/events/#{event_id}"

          routing.is do # rubocop:disable Metrics/BlockLength
            # GET /events/[event_id]
            routing.get do
              event_data, policies_data = GetEventDetail.new(App.config).call(@current_account, event_id)
              policy = PolicySummary.new(policies_data)
              event = Event.new(event_data)

              view :event_detail, locals: { event:, policy: }
            rescue GetEventDetail::NotFoundError => e
              flash[:error] = e.message
              routing.redirect '/events'
            end

            # POST /events/[event_id]
            routing.post do
              if @current_account.logged_in?
                case routing.params['action']
                when 'edit'
                  event = Form::Event.new.call(routing.params)
                  raise Form::ValidationError, Form.validation_errors(event) if event.failure?

                  EditEvent.new(App.config).call(@current_account, event_id, routing.params)
                  flash[:success] = 'Event updated successfully'
                  routing.redirect @current_event_route
                when 'delete'
                  DeleteEvent.new(App.config).call(@current_account, event_id)
                  flash[:success] = 'Event deleted'
                  routing.redirect '/events'
                end
              else
                flash[:notice] = 'Please login'
                routing.redirect '/auth/login'
              end
            rescue EditEvent::ForbiddenError, EditEvent::InvalidRequestError, Form::ValidationError => e
              flash[:error] = e.message
              routing.redirect @current_event_route
            end
          end

          routing.on 'participant' do # rubocop:disable Metrics/BlockLength
            # POST /events/[event_id]/participant
            routing.post do # rubocop:disable Metrics/BlockLength
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
                  routing.redirect @current_event_route
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
              routing.redirect @current_event_route
            end
          end

          # POST /events/[event_id]/co_organizer
          routing.on 'co_organizer' do # rubocop:disable Metrics/BlockLength
            routing.post do
              if @current_account.logged_in?
                case routing.params['action']
                when 'add'
                  co_organzier = Form::AddParticipant.new.call(routing.params)
                  raise Form::ValidationError, Form.validation_errors(co_organzier) if co_organzier.failure?

                  AddCoOrganizer.new(App.config).call(@current_account, event_id, routing.params['email'])
                  flash[:notice] = 'Co-organizer added successfully'
                when 'remove'
                  co_organzier = Form::AddParticipant.new.call(routing.params)
                  raise Form::ValidationError, Form.validation_errors(co_organzier) if co_organzier.failure?

                  RemoveCoOrganizer.new(App.config).call(@current_account, event_id, routing.params['email'])
                  flash[:notice] = 'Co-organizer removed successfully'
                else
                  flash[:error] = 'Invalid action'
                end

                routing.redirect @current_event_route
              else
                flash[:notice] = 'Please login'
                routing.redirect '/auth/login'
              end
            rescue AddCoOrganizer::ForbiddenError, RemoveCoOrganizer::ForbiddenError,
                   Form::ValidationError => e
              flash[:error] = e.message
              routing.redirect @current_event_route
            end
          end

          routing.on 'applicants' do # rubocop:disable Metrics/BlockLength
            # POST /events/[event_id]/applicants
            routing.post do
              if @current_account.logged_in?
                case routing.params['action']
                when 'approve'
                  applicant = Form::AddParticipant.new.call(routing.params)
                  raise Form::ValidationError, Form.validation_errors(applicant) if applicant.failure?

                  ApproveEventApplication.new(App.config).call(@current_account, event_id, routing.params['email'])
                  flash[:notice] = 'Applicant approved'
                when 'reject'
                  applicant = Form::AddParticipant.new.call(routing.params)
                  raise Form::ValidationError, Form.validation_errors(applicant) if applicant.failure?

                  RejectEventApplication.new(App.config).call(@current_account, event_id, routing.params['email'])
                  flash[:notice] = 'Applicant rejected'
                else
                  flash[:error] = 'Invalid action'
                end
              else
                flash[:notice] = 'Please login'
                routing.redirect '/auth/login'
              end

              routing.redirect @current_event_route
            rescue ApproveEventApplication::ForbiddenError, RejectEventApplication::ForbiddenError,
                   Form::ValidationError => e
              flash[:error] = e.message
              routing.redirect @current_event_route
            end
          end

          routing.on 'map' do
            # GET /events/[event_id]/map
            routing.get do
              event_data, _policies_data = GetEventDetail.new(App.config).call(@current_account, event_id)
              postits_data = GetEventPostits.new(App.config).call(@current_account, event_id)

              event = Event.new(event_data)
              postits = Postits.new(postits_data).all

              view :map, layout_opts: { locals: { has_map: true } }, locals: { event:, postits: }
            end
          end

          # POST /events/[event_id]/location
          routing.on 'location' do
            routing.post do
              response.headers['Content-Type'] = 'application/json'

              location_data = Form::Location.new.call(routing.params)

              accounts = UpdateAccountLocation.new(App.config).call(
                @current_account, location_data[:latitude], location_data[:longitude], event_id
              )

              accounts.to_json
            rescue UpdateAccountLocation::ApiError => e
              response.status = 500
              { error: e.message }.to_json
            end
          end
        end
      end
    end
  end
end
