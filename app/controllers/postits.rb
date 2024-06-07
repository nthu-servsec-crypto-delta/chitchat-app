# frozen_string_literal: true

require 'roda'

module ChitChat
  # ChitChat App
  class App < Roda
    route('postits') do |routing| # rubocop:disable Metrics/BlockLength
      routing.on do # rubocop:disable Metrics/BlockLength
        routing.is do # rubocop:disable Metrics/BlockLength
          # GET /postits
          routing.get do
            if @current_account.logged_in?
              postits_data = GetAccountPostits.new(App.config).call(@current_account)

              postits = Postits.new(postits_data).all

              view :postits_list, locals: { postits: }
            else
              flash[:notice] = 'Please login'
              routing.redirect '/auth/login'
            end
          end

          # POST /postits
          routing.post do
            if @current_account.logged_in?
              postit_data = {
                location: {
                  latitude: routing.params['latitude'],
                  longitude: routing.params['longitude']
                },
                message: routing.params['message']
              }

              CreatePostit.new(App.config).call(@current_account, postit_data)

              flash[:notice] = 'Postit created'
              routing.redirect '/postits'
            else
              flash[:notice] = 'Please login'
              routing.redirect '/auth/login'
            end
          rescue CreatePostit::ValidationError => e
            flash[:error] = e.message
            routing.redirect '/postits'
            view :postits_list, locals: { postits: }
          else
            flash[:notice] = 'Please login'
            routing.redirect '/auth/login'
          end
        end
      end
    end
  end
end
