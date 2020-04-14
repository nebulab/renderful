# frozen_string_literal: true

module Renderful
  module Provider
    class Contentful < Base
      def initialize(options)
        super

        fail ArgumentError, 'contentful option is required!' unless contentful
      end

      def cache_prefix
        :contentful
      end

      def find_entry(entry_id)
        entry = contentful.entry(entry_id)
        raise Error::EntryNotFoundError, entry_id unless entry

        wrap_entry(entry)
      end

      def cache_keys_to_invalidate(webhook_body)
        params = webhook_body.is_a?(String) ? JSON.parse(webhook_body) : webhook_body

        keys_to_invalidate = [ContentEntry.build_cache_key(self, id: params['sys']['id'])]
        keys_to_invalidate += contentful.entries(links_to_entry: params['sys']['id']).map do |entry|
          ContentEntry.build_cache_key(self, id: entry.id)
        end

        {
          keys: keys_to_invalidate,
          patterns: [],
        }
      end

      private

      def wrap_entry(entry)
        ContentEntry.new(
          provider: self,
          id: entry.id,
          content_type: entry.content_type.id,
          fields: entry.fields,
        )
      end

      def entries_linking_to(entry_id); end

      def contentful
        options[:contentful]
      end
    end
  end
end
