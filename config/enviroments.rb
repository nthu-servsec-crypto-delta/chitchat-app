# frozen_string_literal: true

require 'roda'
require 'figaro'
require 'logger'
require 'rack/session'
require 'rack/session/redis'
require_relative '../require_app'

require_app('lib')

module ChitChat
  # Configuration for the API
  class App < Roda
    plugin :environments

    # Environment variables setup
    Figaro.application = Figaro::Application.new(
      environment:,
      path: File.expand_path('config/app.yml')
    )
    Figaro.load
    def self.config = Figaro.env

    # Session configuration
    ONE_MONTH = 30 * 24 * 60 * 60
    @redis_url = ENV.delete('REDISCLOUD_URL')
    SecureMessage.setup(ENV.delete('MSG_KEY'))
    SignedMessage.setup(config)
    SecureSession.setup(@redis_url)

    configure :development, :test do
      use Rack::Session::Pool,
          expire_after: ONE_MONTH
    end

    configure :production do
      use Rack::Session::Redis,
          expire_after: ONE_MONTH,
          redis_server: @redis_url
    end

    # HTTP Request logging
    configure :development, :production do
      plugin :common_logger, $stdout
    end

    # Custom events logging
    LOGGER = Logger.new($stderr)
    def self.logger = LOGGER

    configure :development, :test do
      logger.level = Logger::ERROR
    end

    # Console/Pry configuration
    configure :development, :test do
      require 'pry'

      # Allows running reload! in pry to restart entire app
      def self.reload!
        exec 'pry -r ./spec/app_test_loader'
      end
    end
  end
end
