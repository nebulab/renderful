# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Renderful::CacheInvalidator do
  subject(:invalidator) { described_class.new(client) }

  let(:client) do
    instance_double('Renderful::Client', cache: cache)
  end

  let(:cache) do
    instance_spy('Renderful::Cache')
  end

  describe '#process_webhook' do
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
      allow(cache).to receive(:key_for)
        .with(content_type_id: 'moduleImageBanner', entry_id: '6hxhiF6EcKklWANW9BBlVY')
        .and_return('contentful/moduleImageBanner/6hxhiF6EcKklWANW9BBlVY')
    end

    it 'invalidates the cache for the updated entry' do
      invalidator.process_webhook(payload)

      expect(cache).to have_received(:delete)
        .with('contentful/moduleImageBanner/6hxhiF6EcKklWANW9BBlVY')
    end
  end
end
