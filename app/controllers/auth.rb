# frozen_string_literal: true

require 'roda'
require_relative 'app'
require_relative '../services/account_authenticate'
require_relative '../services/register_account'

module ChitChat
  # ChitChat App
  class App < Roda
    route('auth') do |routing| # rubocop:disable Metrics/BlockLength
      @login_route = '/auth/login'

      routing.is 'login' do # rubocop:disable Metrics/BlockLength
        # GET /auth/login
        routing.get do
          if session[:current_account].nil?
            view 'login'
          else
            routing.redirect '/'
          end
        end

        # POST /auth/login
        routing.post do
          account = AccountAuthenticate.new(App.config).call(
            username: routing.params['username'],
            password: routing.params['password']
          )

          SecureSession.new(session).set(:current_account, account)
          flash[:success] = "Hi, #{account['username']}"
          routing.redirect '/'
        rescue AccountAuthenticate::UnauthorizedError
          flash.now[:error] = 'Invalid username or password'
          response.status = 403
          view 'login'
        rescue AccountAuthenticate::ApiServerError => e
          App.logger.warn "API server error: #{e.inspect}"
          App.logger.warn e.backtrace.join('\n')

          flash[:error] = 'Something went wrong. Please try again later.'
          response.status = 500
          routing.redirect @login_route
        end
      end

      routing.is 'logout' do
        # GET /auth/logout
        routing.get do
          SecureSession.new(session).delete(:current_account)
          flash[:notice] = 'You have been logged out'
          routing.redirect '/'
        end
      end

      @register_route = '/auth/register'
      routing.is 'register' do
        # GET /auth/register
        routing.get do
          view 'register'
        end

        # POST /auth/register
        routing.post do
          AccountRegister.new(App.config).call(
            email: routing.params['email'],
            username: routing.params['username'],
            password: routing.params['password']
          )

          flash[:success] = 'Account created successfully'
          routing.redirect @login_route
        rescue AccountRegister::InvalidAccount => e
          App.logger.error "ERROR CREATING ACCOUNT: #{e.inspect}"
          App.logger.error e.backtrace.join('\n')

          flash.now[:error] = 'Cannot register account with provided information'
          routing.redirect @register_route
        end
      end
    end
  end
end
