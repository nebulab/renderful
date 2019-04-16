# frozen_string_literal: true

module Renderful
  class NoRendererError < StandardError
    attr_reader :entry

    def initialize(entry, *args)
      @entry = entry

      super "Cannot find renderer for content type #{entry.content_type.id}", *args
    end
  end
end
