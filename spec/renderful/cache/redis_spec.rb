# frozen_string_literal: true

require 'spec_Helper'

require 'redis'

RSpec.describe Renderful::Cache::Redis do
  subject(:cache) { described_class.new(redis) }

  let(:redis) { instance_spy('Redis') }

  describe '#exist?' do
    context 'when the key exists in Redis' do
      before do
        allow(redis).to receive(:exists)
          .with('cache_key')
          .and_return(true)
      end

      it 'returns true' do
        expect(cache.exist?('cache_key')).to eq(true)
      end
    end

    context 'when the key does not exist in Redis' do
      before do
        allow(redis).to receive(:exists)
          .with('cache_key')
          .and_return(false)
      end

      it 'returns false' do
        expect(cache.exist?('cache_key')).to eq(false)
      end
    end
  end

  describe '#write' do
    it 'writes the key to Redis' do
      cache.write('key', 'value')

      expect(redis).to have_received(:set).with('key', 'value')
    end
  end

  describe '#read' do
    before do
      allow(redis).to receive(:get).with('key').and_return('value')
    end

    it 'reads the key from Redis' do
      expect(cache.read('key')).to eq('value')
    end
  end

  describe '#delete' do
    it 'deletes the key from Redis' do
      cache.delete('key')

      expect(redis).to have_received(:del).with('key')
    end
  end
end
