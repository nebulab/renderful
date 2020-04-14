# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Renderful::Provider::Prismic do
  subject { described_class.new(prismic: prismic) }

  let(:prismic) { instance_double('Prismic::API') }

  describe '#cache_prefix' do
    it 'returns prismic' do
      expect(subject.cache_prefix).to eq(:prismic)
    end
  end

  describe '#find_entry' do
    before do
      allow(prismic).to receive(:getByID)
        .with(entry_id)
        .and_return(OpenStruct.new(
                      fragments: { 'foo' => 'bar' },
                      type: 'test_content_type',
                      id: entry_id,
                    ))
    end

    let(:entry_id) { 'test_entry_id' }

    it 'maps Prismic fragments to the content entry' do
      content_entry = subject.find_entry(entry_id)

      expect(content_entry.fields).to eq('foo' => 'bar')
    end

    it 'maps the Prismic document type ID to the content entry' do
      content_entry = subject.find_entry(entry_id)

      expect(content_entry.content_type).to eq('test_content_type')
    end

    it 'maps the Prismic document ID to the content entry' do
      content_entry = subject.find_entry(entry_id)

      expect(content_entry.id).to eq(entry_id)
    end

    it 'sets the provider on the content entry' do
      content_entry = subject.find_entry(entry_id)

      expect(content_entry.provider).to eq(subject)
    end

    context 'when entry not found' do
      it 'raises an error' do
        allow(prismic).to receive(:getByID)
          .with(entry_id)
          .and_return(nil)

        expect do
          subject.find_entry(entry_id)
        end.to raise_error(Renderful::Error::EntryNotFoundError)
      end
    end
  end

  describe '#cache_keys_to_invalidate' do
    let(:payload) do
      <<~JSON
        {
          "type": "api-update",
          "masterRef": "XoXF-BAAAB8AApSb",
          "releases": {},
          "masks": {},
          "tags": {},
          "experiments": {},
          "domain": "renderfultest",
          "apiUrl": "https://renderfultest.prismic.io/api",
          "secret": null
        }
      JSON
    end

    it 'invalidates all cache keys for Prismic' do
      result = subject.cache_keys_to_invalidate(payload)

      expect(result[:patterns]).to eq(['renderful/prismic/*'])
    end

    it 'does not invalidate any keys by exact match' do
      result = subject.cache_keys_to_invalidate(payload)

      expect(result[:keys]).to eq([])
    end
  end
end
