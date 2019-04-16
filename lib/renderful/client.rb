# frozen_string_literal: true

module Renderful
  class Client
    attr_reader :contentful, :renderers

    def initialize(contentful:, renderers: {})
      @contentful = contentful
      @renderers = renderers
    end

    def render(entry)
      renderer = renderers[entry.content_type.id]

      unless renderer
        fail NoRendererError, entry
      end

      renderer.new(entry, contentful: contentful).render
    end
  end
end
