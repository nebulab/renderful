# frozen_string_literal: true

module Renderful
  class CacheInvalidator
    attr_reader :client

    def initialize(client)
      @client = client
    end

    def process_webhook(body)
      params = body.is_a?(String) ? JSON.parse(body) : body

      client.cache.delete(client.cache.key_for(
        content_type_id: params['sys']['contentType']['sys']['id'],
        entry_id: params['sys']['id'],
      ))
    end
  end
end
