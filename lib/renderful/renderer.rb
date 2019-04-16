# frozen_string_literal: true

module Renderful
  class Renderer
    attr_reader :entry, :contentful

    def initialize(entry, contentful:)
      @entry = entry
      @contentful = contentful
    end

    def render
      raise NotImplementedError
    end
  end
end
