# frozen_string_literal: true

module Renderful
  class ContentEntry
    attr_reader :provider, :id, :content_type, :fields

    class << self
      def build_cache_key(provider, id: nil)
        ['renderful', provider.cache_prefix, id || '*'].join('/')
      end
    end

    def initialize(provider:, id:, content_type: nil, fields: {})
      @provider = provider
      @id = id
      @content_type = content_type
      @fields = fields
    end

    def cache_key
      self.class.build_cache_key(provider, id: id)
    end
  end
end
