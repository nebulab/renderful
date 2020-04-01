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

      def delete(key)
        # noop
      end

      def fetch(_key)
        nil
      end
    end
  end
end
