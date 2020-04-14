# frozen_string_literal: true

module Renderful
  module Provider
    class Prismic < Base
      def initialize(options)
        super

        fail ArgumentError, 'prismic option is required!' unless prismic
      end

      def cache_prefix
        :prismic
      end

      def find_entry(entry_id)
        entry = prismic.getByID(entry_id)
        raise Error::EntryNotFoundError, entry_id unless entry

        wrap_entry(entry)
      end

      def cache_keys_to_invalidate(_webhook_body)
        {
          keys: [],
          patterns: ['renderful/prismic/*'],
        }
      end

      private

      def wrap_entry(entry)
        ContentEntry.new(
          provider: self,
          id: entry.id,
          content_type: entry.type,
          fields: entry.fragments,
        )
      end

      def prismic
        options[:prismic]
      end
    end
  end
end
