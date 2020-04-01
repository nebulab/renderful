# frozen_string_literal: true

module Renderful
  module Component
    class Rails < Base
      def render
        renderer.render(partial: view, locals: locals.merge(default_locals))
      end

      private

      def renderer
        ActionController::Base.renderer
      end

      def locals
        {}
      end

      def view
        "renderful/#{entry.content_type.id.demodulize.underscore}"
      end

      def default_locals
        { entry: entry, client: client, component: self }
      end
    end
  end
end
