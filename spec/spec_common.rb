# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'

require_relative 'app_test_loader'

API_URL = app.config.API_URL
