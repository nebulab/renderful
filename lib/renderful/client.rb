# frozen_string_literal: true

module Renderful
  class Client
    attr_reader :provider, :components, :cache

    def initialize(provider:, components:, cache: Cache::Null)
      @provider = provider
      @components = components
      @cache = cache
    end

    def render(entry_id)
      content_entry = ContentEntry.new(provider: provider, id: entry_id)

      cache.fetch(content_entry.cache_key) do
        content_entry.hydrate
        component_for_entry(content_entry).render
      end
    end

    def invalidate_cache_from_webhook(body)
      provider.cache_keys_to_invalidate(body).each do |cache_key|
        cache.delete(cache_key)
      end
    end

    private

    def component_klass_for_entry(content_entry)
      components[content_entry.content_type] || fail(Error::NoComponentError, content_entry)
    end

    def component_for_entry(content_entry)
      component_klass_for_entry(content_entry).new(content_entry, client: self)
    end
  end
end
