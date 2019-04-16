# frozen_string_literal: true

require 'contentful'

require 'renderful/client'
require 'renderful/component'
require 'renderful/version'

module Renderful
  class Error < StandardError; end

  class << self
    attr_accessor :space, :access_token, :mappings

    def configure
      yield self
    end
  end
end
