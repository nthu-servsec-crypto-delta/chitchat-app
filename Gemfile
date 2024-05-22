# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

gem 'json'

# Web
gem 'puma'
gem 'rack-session'
gem 'roda'
gem 'slim'

gem 'http'

# Configuration
gem 'figaro'
gem 'rake'

# Security
gem 'bundler-audit'
gem 'rack-ssl-enforcer'
gem 'rbnacl'

# Testing
group :test do
  gem 'rack-test'
  gem 'rerun'
  gem 'webmock'
end

# Debugging
group :development do
  gem 'pry'
end

# Quality
group :rubocop do
  gem 'rubocop'
  gem 'rubocop-performance'
end
