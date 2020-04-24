# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Renderful::Client do
  subject(:client) do
    described_class.new(
      provider: provider,
      components: components,
      cache: cache,
    )
  end

  let(:provider) { instance_double('Renderful::Provider::Base', cache_prefix: :base) }
  let(:components) { {} }
  let(:cache) { instance_double('Renderful::Cache::Base') }

  let(:content_type_id) { 'testContentType' }
  let(:component_klass) { class_double('Renderful::Component::Base') }

  describe '#render' do
    let(:entry_id) { 'entry_id' }

    context 'when the output has been cached' do
      before do
        allow(cache).to receive(:fetch)
          .with(an_instance_of(String))
          .and_return('cached output')
      end

      context 'when a component has been registered for the provided content type' do
        let(:components) { { content_type_id => component_klass } }

        it 'returns the cached output' do
          result = client.render(entry_id)

          expect(result).to eq('cached output')
        end
      end

      context 'when no component has been registered for the provided content type' do
        let(:components) { {} }

        it 'returns the cached output' do
          result = client.render(entry_id)

          expect(result).to eq('cached output')
        end
      end
    end

    context 'when the output has not been cached' do
      let(:entry) { instance_double('Renderful::ContentEntry', content_type: 'testContentType', fields: {}) }

      before do
        allow(cache).to receive(:fetch).with(an_instance_of(String)) { |_, &block| block.call }

        allow(provider).to receive(:find_entry)
          .with(an_instance_of(String))
          .and_return(entry)

        component = instance_double('Renderful::Component::Base')
        allow(component_klass).to receive(:new)
          .with(entry: entry, client: client)
          .and_return(component)
        allow(component).to receive(:render)
          .and_return('render_output')
      end

      context 'when a component has been registered for the provided content type' do
        let(:components) { { content_type_id => component_klass } }

        it 'renders the content type with its component' do
          result = client.render(entry_id, view_context: 'dummy context')

          expect(result).to eq('render_output')
        end
      end

      context 'when no component has been registered for the provided content type' do
        let(:components) { {} }

        it 'raises a NoComponentError' do
          expect { client.render(entry_id) }.to raise_error(Renderful::Error::NoComponentError)
        end
      end
    end
  end

  describe '#invalidate_cache_from_webhook' do
    let(:cache) { instance_spy('Renderful::Cache::Base') }

    let(:payload) { 'dummy payload' }

    let(:returned_keys) { %w[provider:key1 provider:key2] }
    let(:returned_patterns) { %w[provider:*] }

    before do
      allow(provider).to receive(:cache_keys_to_invalidate)
        .with(payload)
        .and_return(keys: returned_keys, patterns: returned_patterns)
    end

    context 'when cache keys are returned for invalidation' do
      it 'invalidates the cache keys returned by the provider' do
        client.invalidate_cache_from_webhook(payload)

        expect(cache).to have_received(:delete).with('provider:key1', 'provider:key2')
      end
    end

    context 'when no cache keys are returned for invalidation' do
      let(:returned_keys) { [] }

      it 'does not call #delete at all' do
        client.invalidate_cache_from_webhook(payload)

        expect(cache).not_to have_received(:delete)
      end
    end

    it 'invalidates the pattern returned by the provider' do
      client.invalidate_cache_from_webhook(payload)

      expect(cache).to have_received(:delete_matched).with('provider:*')
    end
  end
end
