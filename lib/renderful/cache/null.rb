# frozen_string_literal: true

module Renderful
  module Cache
    class Null < Base
      def exist?(key)
        false
      end

      def read(key)
        nil
      end

      def write(key, value)
        # noop
      end

      def delete(key)
        # noop
      end

      def fetch(key)
        nil
      end
    end
  end
end
