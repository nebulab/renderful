# frozen_string_literal: true

module Renderful
  class Client
    attr_reader :contentful, :components, :cache

    def initialize(contentful:, components:, cache: nil)
      @contentful = contentful
      @components = components
      @cache = cache
    end

    def render(entry)
      component = components[entry.content_type.id]
      fail(NoComponentError, entry) unless component

      return cache.read(cache_key_for(entry)) if cache&.exist?(cache_key_for(entry))

      component.new(entry, client: self).render.tap do |output|
        cache&.write(cache_key_for(entry), output)
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
