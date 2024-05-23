# frozen_string_literal: true

require_relative 'secure_message'

# Roda actually already encrypts the cookie, but we mustn't assume that it is the case for every other framework
# Encrypt and Decrypt JSON encoded sessions
class SecureSession
  ## Class methods to create and retrieve cookie salt
  SESSION_SECRET_BYTES = 64

  # Generate secret for sessions
  def self.generate_secret
    SecureMessage.encoded_random_bytes(SESSION_SECRET_BYTES)
  end

  def self.setup(redis_url)
    @redis_url = redis_url
  end

  def self.wipe_redis_sessions
    redis = Redis.new(url: @redis_url)
    cnt = redis.dbsize
    redis.flushall
    cnt
  end

  ## Instance methods to store and retrieve encrypted session data
  def initialize(session)
    @session = session
  end

  def set(key, value)
    @session[key] = SecureMessage.encrypt(value)
  end

  def get(key)
    return nil unless @session && @session[key]

    SecureMessage.decrypt(@session[key])
  end

  def delete(key)
    @session.delete(key)
  end
end
