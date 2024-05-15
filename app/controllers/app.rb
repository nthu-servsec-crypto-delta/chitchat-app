# frozen_string_literal: true

require 'roda'
require 'slim'

module ChitChat
  # ChitChat App
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/presentation/views'
    plugin :assets, css: 'style.css', path: 'app/presentation/assets'
    plugin :public, root: 'app/presentation/public'
    plugin :multi_route

    plugin :flash

    route do |routing|
      @current_account = session[:current_account]

      routing.public
      routing.assets
      routing.multi_route

      # GET /
      routing.root do
        view 'home'
      end
    end
  end
end
