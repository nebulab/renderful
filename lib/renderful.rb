require 'contentful'

require 'renderful/array'
require 'renderful/asset'
require 'renderful/client'
require 'renderful/content_type'
require 'renderful/deleted_asset'
require 'renderful/deleted_entry'
require 'renderful/entry'
require 'renderful/link'
require 'renderful/locale'
require 'renderful/space'
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
