# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Renderful::Client do
  subject(:client) { described_class.new(contentful: contentful, renderers: renderers) }

  let(:contentful) { instance_double('Contentful::Client') }
  let(:renderers) do
    {
      'testContentType' => renderer_klass,
    }
  end

  let(:renderer_klass) { class_double('Renderful::Renderer') }

  describe '#render' do
    let(:entry) { OpenStruct.new(content_type: OpenStruct.new(id: content_type_id)) }

    context 'when a renderer has been registered for the provided content type' do
      let(:content_type_id) { 'testContentType' }

      it 'renders the content type with its renderer' do
        renderer = instance_double('Renderful::Renderer')
        allow(renderer_klass).to receive(:new)
          .with(entry, client: client)
          .and_return(renderer)
        allow(renderer).to receive(:render).and_return('render_output')

        result = client.render(entry)

        expect(result).to eq('render_output')
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
