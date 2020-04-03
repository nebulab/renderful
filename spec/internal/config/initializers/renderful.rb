# frozen_string_literal: true

RenderfulPrismicClient = Renderful::Client.new(
  provider: Renderful::Provider::Prismic.new(prismic: Prismic.api(
    'https://renderfultest.cdn.prismic.io/api',
  )),
  components: {
    'page' => PageComponent,
  },
  cache: Rails.cache,
)

RenderfulContentfulClient = Renderful::Client.new(
  provider: Renderful::Provider::Contentful.new(contentful: Contentful::Client.new(
    space: 'secret_space_id',
    access_token: 'secret_access_token'
  )),
  components: {
    'page' => PageComponent,
  },
  cache: Rails.cache,
)
