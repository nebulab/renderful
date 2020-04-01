# frozen_string_literal: true

module Renderful
  module Cache
    class Base
      def exist?(_key)
        raise NotImplementedError
      end

      def read(_key)
        raise NotImplementedError
      end

      def write(_key, _value)
        raise NotImplementedError
      end

      def delete(_key)
        raise NotImplementedError
      end

      def fetch(key)
        raise NotImplementedError
      end
    end
  end
end
