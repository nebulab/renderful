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
end
