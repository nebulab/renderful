module Renderful
  class ContentEntry
    attr_reader :provider, :id, :content_type, :fields

    def initialize(provider:, id:, content_type: nil, fields: {})
      @provider = provider
      @id = id
      @content_type = content_type
      @fields = fields
    end

    def cache_key
      "renderful/#{provider.cache_prefix}/#{id}"
    end

    def hydrate
      other_entry = provider.find_entry(id)

      @content_type = other_entry.content_type
      @fields = other_entry.fields

      self
    end
  end
end
