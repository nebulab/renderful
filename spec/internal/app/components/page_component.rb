# frozen_string_literal: true

class PageComponent < ViewComponent::Base
  def initialize(entry:, client:)
    @entry = entry
    @client = client
  end

  def call
    normalized_fields[:title]
  end

  private

  def normalized_fields
    @normalized_fields ||= @entry.fields.with_indifferent_access.transform_values do |field|
      field.respond_to?(:as_text) ? field.as_text : field
    end
  end
end
