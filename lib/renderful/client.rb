# frozen_string_literal: true

module Renderful
  class Client
    attr_reader :contentful, :renderers, :cache

    def initialize(contentful:, renderers:, cache: nil)
      @contentful = contentful
      @renderers = renderers
      @cache = cache
    end

    def render(entry)
      renderer = renderers[entry.content_type.id]
      fail(NoRendererError, entry) unless renderer

      return cache.read(cache_key_for(entry)) if cache.exist?(cache_key_for(entry))

      renderer.new(entry, client: self).render.tap do |output|
        cache.write(cache_key_for(entry), output)
      end
    end

    def cache_key_for(entry)
      if entry.respond_to?(:content_type)
        cache_key_for(
          content_type_id: entry.content_type.id,
          entry_id: entry.id,
        )
      else
        "contentful/#{entry.fetch(:content_type_id)}/#{entry.fetch(:entry_id)}"
      end
    end
  end
end
