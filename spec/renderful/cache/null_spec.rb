# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Renderful::Cache::Null do
  subject(:cache) { described_class.new }

  describe '#exist?' do
    it 'returns false' do
      expect(cache.exist?('key')).to eq(false)
    end
  end

  describe '#write' do
    it 'is a no-op' do
      expect { cache.write('key', 'value') }.not_to raise_error
    end
  end

  describe '#read' do
    it 'returns nil' do
      expect(cache.read('key')).to eq(nil)
    end
  end

  describe '#delete' do
    it 'is a no-op' do
      expect { cache.delete('key') }.not_to raise_error
    end
  end

  describe '#fetch' do
    it 'always yields' do
      expect(cache.fetch('key') { 'value' }).to eq('value')
    end
  end
end
