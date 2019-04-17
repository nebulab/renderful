# frozen_string_literal: true

module Renderful
  class Cache
    def key_for(entry)
      if entry.is_a?(Contentful::Entry)
        key_for(
          content_type_id: entry.content_type.id,
          entry_id: entry.id,
        )
      else
        "contentful/#{entry.fetch(:content_type_id)}⁄#{entry.fetch(:entry_id)}"
      end
    end

    def exist?(_key)
      raise NotImplementedError
    end

    def read(_key)
      raise NotImplementedError
    end

    def write(_key, _value)
      raise NotImplementedError
    end

    def delete(_key)
      raise NotImplementedError
    end
  end
end
