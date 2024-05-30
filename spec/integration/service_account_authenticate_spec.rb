# frozen_string_literal: true

require_relative '../spec_common'
require 'webmock/minitest'

describe 'Authenticate Service Spec' do
  before do
    @test_credentials = {
      username: 'admin',
      password: 'SecurePassword123!'
    }

    @invalid_credentials = {
      username: 'admin',
      password: 'admin'
    }

    @test_user = {
      id: 1,
      username: 'admin',
      email: 'admin@adm.in'
    }
  end

  after do
    WebMock.reset!
  end

  describe 'Account Authenticate Service' do
    it 'HAPPY: should login as an authenticated user' do
      auth_account_file = 'spec/fixtures/auth_account.json'
      auth_account_fixture = File.read(auth_account_file)

      WebMock.stub_request(:post, "#{API_URL}/auth/authenticate")
             .with(body: @test_credentials.to_json)
             .to_return(body: auth_account_fixture, status: 200, headers: { 'Content-Type' => 'application/json' })

      response = ChitChat::AccountAuthenticate.new(app.config).call(**@test_credentials)
      account = response['account']

      _(account).wont_be_nil
      _(account['id']).must_equal @test_user[:id]
      _(account['username']).must_equal @test_user[:username]
      _(account['email']).must_equal @test_user[:email]
    end

    it 'SAD: should reject invalid credentials' do
      WebMock.stub_request(:post, "#{API_URL}/auth/authenticate")
             .with(body: @invalid_credentials.to_json)
             .to_return(
               body: { message: 'Invalid credentials' }.to_json,
               status: 403,
               headers: { 'Content-Type' => 'application/json' }
             )

      _(proc {
        ChitChat::AccountAuthenticate.new(app.config).call(**@invalid_credentials)
      }).must_raise ChitChat::AccountAuthenticate::UnauthorizedError
    end
  end
end
