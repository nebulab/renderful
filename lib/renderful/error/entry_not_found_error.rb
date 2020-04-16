# frozen_string_literal: true

module Renderful
  module Error
    class EntryNotFoundError < Base
      attr_reader :entry_id

      def initialize(entry_id, *args)
        @entry_id = entry_id

        super "Cannot find entry #{@entry_id}", *args
      end
    end
  end
end
