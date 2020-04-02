# frozen_string_literal: true

module Renderful
  module Cache
    class Null < Base
      def exist?(_key)
        false
      end

      def read(_key)
        nil
      end

      def write(key, value)
        # noop
      end

      def delete(*keys)
        # noop
      end

      def delete_matched(pattern)
        # noop
      end

      def fetch(_key)
        yield
      end
    end
  end
end
