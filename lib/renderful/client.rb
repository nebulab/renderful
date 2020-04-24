# frozen_string_literal: true

module Renderful
  class Client
    attr_reader :provider, :components, :cache

    def initialize(provider:, components:, cache: Cache::Null.new)
      @provider = provider
      @components = components
      @cache = cache
    end

    def render(entry_id, options = {})
      cache.fetch(ContentEntry.build_cache_key(provider, id: entry_id)) do
        content_entry = provider.find_entry(entry_id)
        component = component_for_entry(content_entry)

        if component.respond_to?(:render_in)
          component.render_in(options.fetch(:view_context))
        else
          component.render
        end
      end
    end

    def invalidate_cache_from_webhook(body)
      result = provider.cache_keys_to_invalidate(body)

      cache.delete(*result[:keys]) if result[:keys].any?

      result[:patterns].each do |pattern|
        cache.delete_matched(pattern)
      end
    end

    private

    def component_klass_for_entry(content_entry)
      components[content_entry.content_type] || fail(Error::NoComponentError, content_entry)
    end

    def component_for_entry(content_entry)
      component_klass_for_entry(content_entry).new(entry: content_entry, client: self)
    end
  end
end
