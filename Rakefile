# frozen_string_literal: true

# rubocop:disable Style/HashSyntax
require 'rake/testtask'
require_relative 'require_app'

desc 'Run all tests'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.warning = false
end

task :print_env do
  puts "Environment: #{ENV.fetch('RACK_ENV', 'development')}"
end

desc 'Run application console (pry)'
task :console => :print_env do
  sh 'pry -r ./spec/app_test_loader'
end

desc 'Rake all the Ruby'
task :style do
  sh 'rubocop . --parallel'
end

task :load_lib do
  require_app('lib')
end

# Generate new cryptographic keys
namespace :generate do
  desc 'Create rbnacl key'
  task :msg_key => :load_lib do
    puts "New MSG_KEY (base64): #{SecureMessage.generate_key}"
  end

  desc 'Create cookie secret'
  task :session_secret => :load_lib do
    puts "New SESSION_SECRET (base64): #{SecureSession.generate_secret}"
  end
end

namespace :run do
  # Run in development mode
  desc 'Run Web App in development mode'
  task :dev => :print_env do
    sh 'puma -p 9292'
  end
end
# rubocop:enable Style/HashSyntax
