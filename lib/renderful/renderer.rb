# frozen_string_literal: true

module Renderful
  class Renderer
    attr_reader :entry, :client

    delegate :render, :contentful, to: :client

    def initialize(entry, client:)
      @entry = entry
      @client = client
    end

    def render
      raise NotImplementedError
    end
  end
end
