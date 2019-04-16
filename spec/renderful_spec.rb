RSpec.describe Renderful do
  describe '.configure' do
    it 'yields itself for configuration' do
      expect { |b| described_class.configure(&b) }.to yield_control
    end
  end
end
