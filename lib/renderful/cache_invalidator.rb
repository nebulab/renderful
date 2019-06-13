# frozen_string_literal: true

module Renderful
  class CacheInvalidator
    attr_reader :client

    def initialize(client)
      @client = client
    end

    def process_webhook(body)
      return unless client.cache

      params = body.is_a?(String) ? JSON.parse(body) : body

      client.cache.delete(client.cache_key_for(
        content_type_id: params['sys']['contentType']['sys']['id'],
        entry_id: params['sys']['id'],
      ))

      client.contentful.entries(links_to_entry: params['sys']['id']).each do |linking_entry|
        client.cache.delete(client.cache_key_for(linking_entry))
      end
    end
  end
end
