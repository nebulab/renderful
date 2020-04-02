# frozen_string_literal: true

module Renderful
  module Cache
    class Redis < Base
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

      def delete(*keys)
        redis.del(*keys)
      end

      def delete_matched(pattern)
        keys = redis.scan_each(match: pattern).to_a
        delete(*keys)
      end

      def fetch(key)
        return read(key) if exist?(key)

        yield.tap do |value|
          write(key, value)
        end
      end
    end
  end
end
