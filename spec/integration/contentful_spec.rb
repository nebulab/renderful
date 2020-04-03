# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Contentful integration test', type: :feature do
  around do |example|
    VCR.use_cassette('contentful', &example)
  end

  it 'renders Contentful entries' do
    visit '/contentful'

    expect(page.body.strip).to eq('Homepage')
  end
end
