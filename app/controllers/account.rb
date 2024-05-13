# frozen_string_literal: true

require 'roda'
require_relative 'app'

module ChitChat
  # ChitChat App
  class App < Roda
    route('account') do |routing|
      routing.on do
        view 'account'
      end
    end
  end
end
