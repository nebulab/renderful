# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Renderful::Provider::Contentful do
  subject { described_class.new(contentful: contentful) }

  let(:contentful) { instance_double('Contentful::Client') }

  describe '#cache_prefix' do
    it 'returns contentful' do
      expect(subject.cache_prefix).to eq(:contentful)
    end
  end

  describe '#find_entry' do
    before do
      allow(contentful).to receive(:entry)
        .with(entry_id)
        .and_return(OpenStruct.new(
                      fields: { 'foo' => 'bar' },
                      content_type: OpenStruct.new(id: 'test_content_type'),
                      id: entry_id,
                    ))
    end

    let(:entry_id) { 'test_entry_id' }

    it 'maps Contentful fields to the content entry' do
      content_entry = subject.find_entry(entry_id)

      expect(content_entry.fields).to eq('foo' => 'bar')
    end

    it 'maps the Contentful content type ID to the content entry' do
      content_entry = subject.find_entry(entry_id)

      expect(content_entry.content_type).to eq('test_content_type')
    end

    it 'maps the Contentful entry ID to the content entry' do
      content_entry = subject.find_entry(entry_id)

      expect(content_entry.id).to eq(entry_id)
    end

    it 'sets the provider on the content entry' do
      content_entry = subject.find_entry(entry_id)

      expect(content_entry.provider).to eq(subject)
    end
  end

  describe '#cache_keys_to_invalidate' do
    let(:payload) do
      <<~JSON
        {
          "sys": {
            "space": {
              "sys": {
                "type": "Link",
                "linkType": "Space",
                "id": "uzfpz86mcpi5"
              }
            },
            "id": "6hxhiF6EcKklWANW9BBlVY",
            "type": "Entry",
            "createdAt": "2019-02-19T20:18:52.397Z",
            "updatedAt": "2019-04-17T12:30:40.227Z",
            "environment": {
              "sys": {
                "id": "master",
                "type": "Link",
                "linkType": "Environment"
              }
            },
            "createdBy": {
              "sys": {
                "type": "Link",
                "linkType": "User",
                "id": "7feCK4fgU19fUFFQsMcUmR"
              }
            },
            "updatedBy": {
              "sys": {
                "type": "Link",
                "linkType": "User",
                "id": "6N31zQDHY87IGFgJEJ030m"
              }
            },
            "publishedCounter": 0,
            "version": 5,
            "contentType": {
              "sys": {
                "type": "Link",
                "linkType": "ContentType",
                "id": "moduleImageBanner"
              }
            }
          },
          "fields": {
            "headline": {
              "en-US": "Testing"
            }
          }
        }
      JSON
    end

    before do
      allow(contentful).to receive(:entries)
        .with(links_to_entry: '6hxhiF6EcKklWANW9BBlVY')
        .and_return([OpenStruct.new(
          fields: { 'foo' => 'bar' },
          content_type: OpenStruct.new(id: 'test_content_type'),
          id: 'linking_entry_id',
        )])

      allow(Renderful::ContentEntry).to receive(:new).with(a_hash_including(id: '6hxhiF6EcKklWANW9BBlVY'))
                                                     .and_return(instance_double('ContentEntry', id: '6hxhiF6EcKklWANW9BBlVY', cache_key: 'cache/6hxhiF6EcKklWANW9BBlVY'))

      allow(Renderful::ContentEntry).to receive(:new).with(a_hash_including(id: 'linking_entry_id'))
                                                     .and_return(instance_double('ContentEntry', id: 'linking_entry_id', cache_key: 'cache/linking_entry_id'))
    end

    it 'returns the cache key for the invalidated entry' do
      expect(subject.cache_keys_to_invalidate(payload)).to include('cache/6hxhiF6EcKklWANW9BBlVY')
    end

    it 'returns the cache keys for any entries linking to the invalidated one' do
      expect(subject.cache_keys_to_invalidate(payload)).to include('cache/linking_entry_id')
    end
  end
end
