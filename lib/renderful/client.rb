# frozen_string_literal: true

module Renderful
  class Client < Delegator
    include Singleton

    class << self
      def method_missing(method, *args, &block)
        instance.respond_to?(method) ? instance.send(method, *args, &block) : super
      end

      def respond_to_missing?(method)
        instance.respond_to?(method) || super
      end
    end

    def initialize
      @client = ::Contentful::Client.new(
        space: Renderful.space,
        access_token: Renderful.access_token,
        dynamic_entries: :auto,
        entry_mapping: Renderful.mappings,
        resource_mapping: {
          'Entry' => Component,
        }
      )
    end

    def __getobj__
      @client
    end
  end
end
