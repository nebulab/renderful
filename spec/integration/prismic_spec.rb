# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Prismic integration test', type: :feature do
  around do |example|
    VCR.use_cassette('prismic', &example)
  end

  it 'renders Contentful entries' do
    visit '/prismic'

    expect(page.body.strip).to eq('Homepage')
  end
end
