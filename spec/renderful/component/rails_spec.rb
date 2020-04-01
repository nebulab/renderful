# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Renderful::Component::Rails do
  subject(:component) do
    TestComponent.new(entry, client: client)
  end

  let(:entry) { OpenStruct.new(content_type: OpenStruct.new(id: 'test')) }
  let(:client) { instance_double('Renderful::Client') }

  before(:all) do
    TestComponent = Class.new(described_class) do
      def locals
        { test_local: 'local_value' }
      end
    end
  end

  describe '#render' do
    it 'renders the correct partial' do
      result = component.render

      expect(result.strip).to eq('test_local is local_value')
    end
  end
end
