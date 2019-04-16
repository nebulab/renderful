require 'spec_helper'

require 'action_controller'

RSpec.describe Renderful::Component do
  subject(:component) do
    TestComponent.new({
      'sys' => {
        space: OpenStruct.new(id: 'space_id'),
        content_type: OpenStruct.new(id: 'test_component'),
      },
    }, {})
  end

  let(:renderer) { instance_spy('ActionController::Renderer') }

  before(:all) do
    TestComponent = Class.new(described_class) do
      def assigns
        { test_assign: 'assign_value' }
      end

      def fields
        { test_field: 'field_value' }
      end

      def locals
        super.merge(test_local: 'local_value')
      end
    end
  end

  before { allow(ActionController::Base).to receive(:renderer).and_return(renderer) }

  describe '#render' do
    it 'infers the correct component view' do
      component.render

      expect(renderer).to have_received(:render).with('renderful/test_component', any_args)
    end

    it 'passes locals to the view' do
      component.render

      expect(renderer).to have_received(:render).with(any_args, a_hash_including(assigns: {
        test_assign: 'assign_value',
      }))
    end

    it 'passes assigns to the view' do
      component.render

      expect(renderer).to have_received(:render).with(any_args, a_hash_including(
        locals: a_hash_including(test_field: 'field_value', test_local: 'local_value'),
      ))
    end
  end
end
