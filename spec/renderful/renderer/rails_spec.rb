# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Renderful::Renderer::Rails do
  subject(:renderer) do
    TestComponentRenderer.new(entry, client: client)
  end

  let(:entry) { OpenStruct.new(content_type: OpenStruct.new(id: 'testComponent')) }
  let(:client) { instance_double('Renderful::Client') }

  before(:all) do
    TestComponentRenderer = Class.new(described_class) do
      def locals
        { test_local: 'local_value' }
      end
    end
  end

  describe '#render' do
    it 'renders the correct partial' do
      result = renderer.render

      expect(result.strip).to eq('test_local is local_value')
    end
  end
end
