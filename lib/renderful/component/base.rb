# frozen_string_literal: true

module Renderful
  module Component
    class Base
      attr_reader :entry, :client

      def initialize(entry:, client:)
        @entry = entry
        @client = client
      end

      def render
        fail NotImplementedError
      end
    end
  end
end
