# frozen_string_literal: true

require 'roda'

module ChitChat
  # ChitChat App
  class App < Roda
    route('postits') do |routing|
      routing.on do
        # GET /postits/
        routing.get do
          if @current_account.logged_in?
            postits_data = GetAllPostits.new(App.config).call(@current_account)

            postits = Postits.new(postits_data).all

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
