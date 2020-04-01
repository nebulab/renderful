# frozen_string_literal: true

module Renderful
  class NoComponentError < StandardError
    attr_reader :entry

    def initialize(entry, *args)
      @entry = entry

      super "Cannot find component for content type #{entry.content_type.id}", *args
    end
  end
end
