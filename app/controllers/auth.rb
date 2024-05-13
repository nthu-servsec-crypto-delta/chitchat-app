# frozen_string_literal: true

require 'roda'
require_relative 'app'
require_relative '../services/account_authenticate'

module ChitChat
  # ChitChat App
  class App < Roda
    route('auth') do |routing| # rubocop:disable Metrics/BlockLength
      view 'login'
    end
  end
end
