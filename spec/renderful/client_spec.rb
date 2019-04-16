# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Renderful::Client do
  subject(:client) { described_class.new(contentful: contentful, renderers: renderers, cache: cache) }

  let(:contentful) { instance_double('Contentful::Client') }
  let(:renderers) do
    {
      'testContentType' => renderer_klass,
    }
  end

  let(:renderer_klass) { class_double('Renderful::Renderer') }

  describe '#render' do
    let(:entry) { OpenStruct.new(content_type: OpenStruct.new(id: content_type_id)) }
    let(:cache) { instance_spy('Renderful::Cache') }

    before do
      allow(cache).to receive(:key_for)
        .with(entry)
        .and_return('cache_key')
    end

    context 'when a renderer has been registered for the provided content type' do
      let(:content_type_id) { 'testContentType' }

      context 'when the output has been cached' do
        before do
          allow(cache).to receive(:exist?)
            .with('cache_key')
            .and_return(true)

          allow(cache).to receive(:read)
            .with('cache_key')
            .and_return('cached output')
        end

        it 'returns the cached output' do
          result = client.render(entry)

          expect(result).to eq('cached output')
        end
      end

      context 'when the output has not been cached' do
        before do
          allow(cache).to receive(:exist?)
            .with('cache_key')
            .and_return(false)

          allow(renderer_klass).to receive(:new)
            .with(entry, client: client)
            .and_return(instance_double('Renderful::Renderer', render: 'render_output'))
        end

        it 'renders the content type with its renderer' do
          result = client.render(entry)

          expect(result).to eq('render_output')
        end

        it 'writes the output to the cache' do
          client.render(entry)

          expect(cache).to have_received(:write).with('cache_key', 'render_output')
        end
      end
    end

    context 'when no renderer has been registered for the provided content type' do
      let(:content_type_id) { 'unknownContentType' }

      it 'raises a NoRendererError' do
        expect {
          client.render(entry)
        }.to raise_error(Renderful::NoRendererError)
      end
    end
  end
end
