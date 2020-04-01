module Renderful
  module Provider
    class Base
      attr_reader :options

      def initialize(options)
        @options = options
      end

      def cache_prefix
        fail NotImplementedError
      end

      def find_entry(entry_id)
        fail NotImplementedError
      end

      def cache_keys_to_invalidate(webhook_body)
        fail NotImplementedError
      end
    end
  end
end
