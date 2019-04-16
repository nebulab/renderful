# frozen_string_literal: true

module Renderful
  class Renderer
    class Rails < Renderer
      def render
        ActionController::Base.renderer.render(view, locals: locals, assigns: assigns)
      end

      private

      def view
        "renderful/#{entry.content_type.id.demodulize.underscore}"
      end

      def locals
        fields
      end

      def assigns
        {}
      end
    end
  end
end
