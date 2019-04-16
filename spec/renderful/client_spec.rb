RSpec.describe Renderful::Client do
  subject { described_class.instance }

  let(:contentful_client) { instance_double('Contentful::Client') }

  before do
    allow(Contentful::Client).to receive(:new).and_return(contentful_client)
  end

  it 'delegates methods to the Contentful client' do
    allow(contentful_client).to receive(:entries).and_return([])

    entries = subject.entries

    expect(entries).to eq([])
  end
end
