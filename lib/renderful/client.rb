# frozen_string_literal: true

module Renderful
  class Client
    attr_reader :contentful, :renderers, :cache

    def initialize(contentful:, renderers: {}, cache: nil)
      @contentful = contentful
      @renderers = renderers
      @cache = cache
    end

    def render(entry)
      renderer = renderers[entry.content_type.id]
      fail(NoRendererError, entry) unless renderer

      return cache.read(cache.key_for(entry)) if cache.exist?(cache.key_for(entry))

      renderer.new(entry, client: self).render.tap do |output|
        cache.write(cache.key_for(entry), output)
      end
    end
  end
end
