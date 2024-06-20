# frozen_string_literal: true

require 'roda'
require 'slim'

module ChitChat
  # ChitChat App
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/presentation/views'
    plugin :assets, css: { base: 'style.css', map: 'map.css' },
                    js: { postits: 'postits.js', event_detail: 'event_detail.js', map: 'map.js' },
                    path: 'app/presentation/assets', group_subdirs: false
    plugin :public, root: 'app/presentation/public'
    plugin :multi_route

    plugin :flash

    route do |routing|
      @current_account = CurrentSession.new(session).current_account
      routing.public
      routing.assets
      routing.multi_route

      # GET /
      routing.root do
        view 'home', locals: { current_account: @current_account }
      end
    end
  end
end
