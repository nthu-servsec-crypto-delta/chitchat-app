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

    @api_account = {
      username: 'admin',
      email: 'admin@adm.in'
    }
  end

  after do
    WebMock.reset!
  end

  describe 'Authenticate Account Service' do
    it 'HAPPY: should login as an authenticated user' do
      auth_account_file = 'spec/fixtures/auth_account.json'

      auth_return_json = File.read(auth_account_file)

      WebMock.stub_request(:post, "#{API_URL}/auth/authenticate")
             .with(body: @test_credentials.to_json)
             .to_return(body: auth_return_json,
                        headers: { 'content-type' => 'application/json' })

      auth = ChitChat::AuthenticateAccount.new(app.config).call(**@test_credentials)
      account = auth[:account]
      _(account).wont_be_nil
      _(account['username']).must_equal @api_account[:username]
      _(account['email']).must_equal @api_account[:email]
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
        ChitChat::AuthenticateAccount.new(app.config).call(**@invalid_credentials)
      }).must_raise ChitChat::AuthenticateAccount::UnauthorizedError
    end
  end
end
