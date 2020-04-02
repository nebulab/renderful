# frozen_string_literal: true

require 'spec_helper'

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
    it 'deletes the keys from Redis' do
      cache.delete('key1', 'key2')

      expect(redis).to have_received(:del).with('key1', 'key2')
    end
  end

  describe '#delete_matched' do
    before do
      allow(redis).to receive(:scan_each)
        .with(match: 'key*')
        .and_return(%w[key1 key2])
    end

    it 'deletes all keys from Redis that match the given pattern' do
      cache.delete_matched('key*')

      expect(redis).to have_received(:del).with('key1', 'key2')
    end
  end

  describe '#fetch' do
    context 'when the key exists in Redis' do
      before do
        allow(redis).to receive(:exists)
          .with('key')
          .and_return(true)

        allow(redis).to receive(:get).with('key').and_return('value')
      end

      it 'returns the stored value' do
        expect(cache.fetch('key') { fail StandardError }).to eq('value')
      end
    end

    context 'when the key does not exist in Redis' do
      before do
        allow(redis).to receive(:exists)
          .with('key')
          .and_return(false)
      end

      it 'writes the key to Redis' do
        cache.fetch('key') { 'value' }

        expect(redis).to have_received(:set).with('key', 'value')
      end

      it 'returns the value' do
        expect(cache.fetch('key') { 'value' }).to eq('value')
      end
    end
  end
end
