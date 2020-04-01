# frozen_string_literal: true

module Renderful
  module Error
    class NoComponentError < Base
      attr_reader :entry

      def initialize(entry, *args)
        @entry = entry

        super "Cannot find component for content type #{entry.content_type}", *args
      end
    end
  end
end
