# frozen_string_literal: true

require 'roda'

require 'rack/ssl-enforcer'
require 'secure_headers'

module ChitChat
  # Configuration for the API
  class App < Roda
    plugin :environments
    plugin :multi_route

    FONT_SRC = %w[https://cdn.jsdelivr.net https://cdnjs.cloudflare.com].freeze
    SCRIPT_SRC = %w[https://cdn.jsdelivr.net https://cdnjs.cloudflare.com].freeze
    STYLE_SRC = %w[https://cdn.jsdelivr.net https://cdnjs.cloudflare.com].freeze
    IMAGE_SRC = %w[https://tile.openstreetmap.org].freeze

    configure :production do
      use Rack::SslEnforcer, hsts: true
    end

    use SecureHeaders::Middleware

    SecureHeaders::Configuration.default do |config| # rubocop:disable Metrics/BlockLength
      config.cookies = {
        secure: true,
        httponly: true,
        samesite: {
          lax: true
        }
      }

      config.x_frame_options = 'DENY'
      config.x_content_type_options = 'nosniff'
      config.x_xss_protection = '1'
      config.x_permitted_cross_domain_policies = 'none'
      config.referrer_policy = 'origin-when-cross-origin'

      # rubocop:disable Lint/PercentStringArray
      config.csp = {
        report_only: false,
        preserve_schemes: true,
        default_src: %w['self'],
        child_src: %w['self'],
        connect_src: %w[wws:],
        img_src: %w['self'],
        font_src: %w['self'] + FONT_SRC,
        script_src: %w['self'] + SCRIPT_SRC,
        style_src: %W['self'] + STYLE_SRC,
        form_action: %w['self'],
        frame_ancestors: %w['none'],
        object_src: %w['none'],
        block_all_mixed_content: true,
        report_uri: %w[/security/report_csp_violation]
      }
      # rubocop:enable Lint/PercentStringArray
    end

    route('security') do |routing|
      # POST security/report_csp_violation
      routing.post 'report_csp_violation' do
        App.logger.warn "CSP VIOLATION: #{request.body.read}"
      end
    end
  end
end
