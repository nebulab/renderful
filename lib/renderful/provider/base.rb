# frozen_string_literal: true

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

      def find_entry(_entry_id)
        fail NotImplementedError
      end

      def cache_keys_to_invalidate(_webhook_body)
        fail NotImplementedError
      end
    end
  end
end
