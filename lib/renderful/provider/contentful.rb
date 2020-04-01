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
        wrap_entry(contentful.entry(entry_id))
      end

      def cache_keys_to_invalidate(webhook_body)
        params = webhook_body.is_a?(String) ? JSON.parse(webhook_body) : webhook_body

        modified_entry = ContentEntry.new(
          provider: self,
          content_type: params['sys']['contentType']['sys']['id'],
          id: params['sys']['id'],
        )

        entries_to_invalidate = [modified_entry] + entries_linking_to(modified_entry)

        entries_to_invalidate.map(&:cache_key)
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

      def entries_linking_to(entry)
        contentful.entries(links_to_entry: entry.id).map(&method(:wrap_entry))
      end

      def contentful
        options[:contentful]
      end
    end
  end
end
