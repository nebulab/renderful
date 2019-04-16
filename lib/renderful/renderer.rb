# frozen_string_literal: true

module Renderful
  class Renderer
    attr_reader :entry, :client

    class << self
      def resolve(field)
        define_method(field) do
          resolve(entry.send(field))
        end
      end
    end

    def initialize(entry, client:)
      @entry = entry
      @client = client
    end

    def render
      raise NotImplementedError
    end

    private

    def resolve(reference)
      if reference.is_a?(Enumerable)
        reference.map(&method(:resolve))
      elsif reference.is_a?(Contentful::Link)
        contentful.resolve(reference)
      else
        reference
      end
    end
  end
end
