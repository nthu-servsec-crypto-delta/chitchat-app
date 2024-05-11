# frozen_string_literal: true

# for pry console

require_relative '../require_app'
require_app

def app
  ChitChat::App
end

unless app.environment == :production
  require 'rack/test'
  include Rack::Test::Methods # rubocop:disable Style/MixinUsage
end
