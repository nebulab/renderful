# frozen_string_literal: true

require 'spec_helper'

require 'action_controller'

RSpec.describe Renderful::Renderer::Rails do
  subject(:renderer) do
    TestComponentRenderer.new(entry, client: client)
  end

  let(:entry) { OpenStruct.new(content_type: OpenStruct.new(id: 'testComponent')) }
  let(:client) { instance_double('Renderful::Client') }

  let(:rails_renderer) { instance_spy('ActionController::Renderer') }

  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    TestComponentRenderer = Class.new(described_class) do
      def locals
        { test_local: 'local_value' }
      end
    end
  end

  before { allow(ActionController::Base).to receive(:renderer).and_return(rails_renderer) }

  describe '#render' do
    it 'returns the output from the ActionController renderer' do
      allow(rails_renderer).to receive(:render).and_return('render_output')

      result = renderer.render

      expect(result).to eq('render_output')
    end

    it 'infers the correct component view' do
      renderer.render

      expect(rails_renderer).to have_received(:render).with(a_hash_including(
        partial: 'renderful/test_component',
      ))
    end

    it 'passes locals to the view' do
      renderer.render

      expect(rails_renderer).to have_received(:render).with(a_hash_including(
        locals: a_hash_including(
          test_local: 'local_value',
        ),
      ))
    end

    it 'passes the entry, renderer and client to the view' do
      renderer.render

      expect(rails_renderer).to have_received(:render).with(a_hash_including(
        locals: a_hash_including(
          entry: entry,
          renderer: renderer,
          client: client,
        ),
      ))
    end
  end
end
