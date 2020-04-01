# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Renderful::ContentEntry do
  subject { described_class.new(provider: provider, id: id, content_type: content_type, fields: fields) }

  let(:provider) { instance_double('Renderful::Provider::Base') }
  let(:id) { :content_entry_id }
  let(:content_type) { nil }
  let(:fields) { {} }

  describe '#cache_key' do
    before do
      allow(provider).to receive(:cache_prefix).and_return('dummy_provider')
    end

    it 'generates a cache key for the content entry' do
      expect(subject.cache_key).to eq('renderful/dummy_provider/content_entry_id')
    end
  end

  describe '#hydrate' do
    before do
      allow(provider).to receive(:find_entry).with(id).and_return(described_class.new(
                                                                    provider: provider,
                                                                    id: id,
                                                                    content_type: 'new_content_type',
                                                                    fields: { 'new' => 'fields' },
                                                                  ))
    end

    it 'hydrates the content entry with the content type from the CMS' do
      subject.hydrate

      expect(subject.content_type).to eq('new_content_type')
    end

    it 'hydrates the content entry with the fields from the CMS' do
      subject.hydrate

      expect(subject.fields).to eq('new' => 'fields')
    end

    it 'returns self' do
      expect(subject.hydrate).to eq(subject)
    end
  end
end
