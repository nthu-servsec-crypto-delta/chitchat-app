# frozen_string_literal: true

require 'roda'
require_relative 'app'
require_relative '../services/authenticate_account'
require_relative '../services/register_account'

require 'uri'

module ChitChat
  # ChitChat App
  class App < Roda # rubocop:disable Metrics/ClassLength
    def github_oauth_url
      base_url = 'https://github.com/login/oauth/authorize'
      client_id = App.config.GITHUB_OAUTH_CLIENT_ID
      scope = App.config.GITHUB_OAUTH_SCOPE

      query = URI.encode_www_form({ client_id:, scope: })
      "#{base_url}?#{query}"
    end

    route('auth') do |routing| # rubocop:disable Metrics/BlockLength
      @login_route = '/auth/login'

      routing.is 'login' do # rubocop:disable Metrics/BlockLength
        # GET /auth/login
        routing.get do
          if CurrentSession.new(session).current_account.logged_out?
            view 'login', locals: { github_oauth_url: }
          else
            routing.redirect '/'
          end
        end

        # POST /auth/login
        routing.post do
          account_info = AuthenticateAccount.new(App.config).call(
            username: routing.params['username'],
            password: routing.params['password']
          )

          current_account = Account.new(
            account_info[:account],
            account_info[:auth_token]
          )

          CurrentSession.new(session).current_account = current_account
          flash[:success] = "Hi, #{current_account.username}"
          routing.redirect '/'
        rescue AuthenticateAccount::UnauthorizedError
          flash.now[:error] = 'Invalid username or password'
          response.status = 403
          view 'login'
        rescue AuthenticateAccount::ApiServerError => e
          App.logger.warn "API server error: #{e.inspect}"
          App.logger.warn e.backtrace.join("\n")

          flash[:error] = 'Something went wrong. Please try again later.'
          response.status = 500
          routing.redirect @login_route
        end
      end

      routing.is 'logout' do
        # GET /auth/logout
        routing.get do
          CurrentSession.new(session).delete
          flash[:notice] = 'You have been logged out'
          routing.redirect '/'
        end
      end

      @register_route = '/auth/register'
      routing.on 'register' do # rubocop:disable Metrics/BlockLength
        routing.is do
          # GET /auth/register
          routing.get do
            view 'register'
          end

          # POST /auth/register
          routing.post do
            VerifyRegistration.new(App.config).call(
              email: routing.params['email'],
              username: routing.params['username']
            )

            flash[:notice] = 'Please check your email to confirm your account'
            routing.redirect '/'
          rescue VerifyRegistration::InvalidRegistrationError => e
            App.logger.error "ERROR CREATING ACCOUNT: #{e.inspect}"
            App.logger.error e.backtrace.join("\n")

            flash[:error] = "Cannot register account: #{e.message}"
            routing.redirect @register_route
          end
        end

        # GET /auth/register/:token
        routing.get String do |registration_token|
          @registration_data = SecureMessage.decrypt(registration_token)
          flash.now[:notice] = 'Email Verified! Please choose a new password'
          view :register_confirm, locals: { registration_token: }
        rescue RbNaCl::CryptoError
          flash[:error] = 'Invalid token'
          routing.redirect '/'
        end
      end

      routing.on 'sso' do
        routing.on 'github' do
          routing.on 'callback' do
            # GET /auth/sso/github/callback
            routing.get do
              gh_account = GitHubOAuthAccount.new(App.config).call(routing.params['code'])

              current_account = Account.new(
                gh_account[:account],
                gh_account[:auth_token]
              )

              CurrentSession.new(session).current_account = current_account
              flash[:success] = "Hi, #{current_account.username}"
              routing.redirect '/'
            rescue GitHubOAuthAccount::UnauthorizedError => e
              flash[:error] = e.message
              routing.redirect @login_route
            rescue StandardError => e
              App.logger.error "GitHub OAuth ERROR: #{e.inspect}"
              App.logger.error e.backtrace.join("\n")

              flash[:error] = 'Something went wrong. Please try again later.'
              response.status = 500
              routing.redirect @login_route
            end
          end
        end
      end
    end
  end
end
