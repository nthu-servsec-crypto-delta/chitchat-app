# frozen_string_literal: true

require 'roda'
require_relative 'app'

module ChitChat
  # ChitChat App
  class App < Roda
    route('account') do |routing| # rubocop:disable Metrics/BlockLength
      @login_route = '/auth/login'
      @register_route = '/auth/register'

      routing.on do # rubocop:disable Metrics/BlockLength
        # GET /account/<username>
        routing.get String do |username|
          if @current_account.logged_in? && @current_account.username == username
            view 'account'
          else
            routing.redirect '/auth/login'
          end
        end

        # POST /account/set_password
        routing.post 'set_password' do
          raise 'Missing registration token' if routing.params['registration_token'].nil?
          raise 'Passwords do not match' unless routing.params['password'] == routing.params['repeat_password']

          registration_data = SecureMessage.decrypt(routing.params['registration_token'])
          @account = AccountRegister.new(App.config).call(
            email: registration_data['email'],
            username: registration_data['username'],
            password: routing.params['password']
          )
          flash[:success] = 'Account created successfully'
          routing.redirect @login_route
        rescue AccountRegister::InvalidAccount => e
          flash[:error] = e.message
          routing.redirect @register_route
        rescue RbNaCl::CryptoError, RbNaCl::LengthError
          flash[:error] = 'Invalid registration token'
          routing.redirect '/'
        rescue StandardError => e
          flash[:error] = e.message
          routing.redirect "/auth/register/#{routing.params['registration_token']}"
        end
      end
    end
  end
end
