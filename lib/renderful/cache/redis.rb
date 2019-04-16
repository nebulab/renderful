# frozen_string_literal: true

module Renderful
  class Cache
    class Redis < Cache
      attr_reader :redis

      def initialize(redis)
        @redis = redis
      end

      def exist?(key)
        redis.exists(key)
      end

      def read(key)
        redis.get(key)
      end

      def write(key, value)
        redis.set(key, value)
      end

      def delete(key)
        redis.del(key)
      end
    end
  end
end
