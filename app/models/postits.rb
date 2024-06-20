# frozen_string_literal: true

require_relative 'postit'

module ChitChat
  # Postits
  class Postits
    attr_reader :all

    def initialize(postits_data)
      @all = to_postits(postits_data)
    end

    private

    def to_postits(postits_data)
      postits_data.map do |postit_data|
        Postit.new(postit_data['attributes'])
      end
    end
  end
end
