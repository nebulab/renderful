# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Renderful::Client do
  subject(:client) do
    described_class.new(contentful: contentful, renderers: renderers, cache: cache)
  end

  let(:contentful) { instance_double('Contentful::Client') }
  let(:renderers) do
    {
      'testContentType' => renderer_klass,
    }
  end

  let(:cache) { instance_spy('Renderful::Cache') }

  let(:renderer_klass) { class_double('Renderful::Renderer') }

  describe '#cache_key_for' do
    context 'with an entry' do
      let(:entry) do
        OpenStruct.new(
          id: 'entry_id',
          content_type: OpenStruct.new(id: 'content_type_id'),
        )
      end

      it 'returns a valid cache key' do
        expect(client.cache_key_for(entry)).to eq('contentful/content_type_id/entry_id')
      end
    end

    context 'with an options hash' do
      let(:options) { { entry_id: 'entry_id', content_type_id: 'content_type_id' } }

      it 'returns a valid cache key' do
        expect(client.cache_key_for(options)).to eq('contentful/content_type_id/entry_id')
      end
    end
  end

  describe '#render' do
    let(:entry) { OpenStruct.new(content_type: OpenStruct.new(id: content_type_id)) }
    let(:cache) { instance_spy('Renderful::Cache') }

    context 'when a renderer has been registered for the provided content type' do
      let(:content_type_id) { 'testContentType' }

      context 'when the output has been cached' do
        before do
          allow(cache).to receive(:exist?)
            .with(an_instance_of(String))
            .and_return(true)

          allow(cache).to receive(:read)
            .with(an_instance_of(String))
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
            .with(an_instance_of(String))
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

          expect(cache).to have_received(:write).with(an_instance_of(String), 'render_output')
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
