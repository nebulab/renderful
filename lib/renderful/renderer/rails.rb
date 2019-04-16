# frozen_string_literal: true

module Renderful
  class Renderer
    class Rails < Renderer
      def render
        ActionController::Base.renderer.render(partial: view, locals: locals)
      end

      private

      def view
        "renderful/#{entry.content_type.id.demodulize.underscore}"
      end

      def locals
        { entry: entry }
      end
    end
  end
end
