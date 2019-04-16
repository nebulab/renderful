# frozen_string_literal: true

module Renderful
  class Component < Contentful::Entry
    def render
      ActionController::Base.renderer.render(view, locals: locals, assigns: assigns)
    end

    def view
      "renderful/#{self.class.to_s.demodulize.underscore}"
    end

    def locals
      fields.merge(content_type: content_type)
    end

    def assigns
      {}
    end
  end
end
