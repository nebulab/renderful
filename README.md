# Renderful

[![CircleCI](https://circleci.com/gh/nebulab/renderful.svg?style=svg)](https://circleci.com/gh/nebulab/renderful)

Welcome! Renderful is a rendering engine for headless CMSs. It allows you to map your content types
to Ruby objects that take care of rendering your content.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'renderful'
```

And then execute:

```console
$ bundle
```

Or install it yourself as:

```console
$ gem install renderful
```

Once you have installed the gem, you can configure it like this:

```ruby
RenderfulClient = Renderful::Client.new(
  provider: Renderful::Provider::DummyCms.new(api_key: 'secretApiKey'), # see "Providers"
  components: {
    'jumbotron' => JumbotronComponent,
  },
)
```

## Usage

Suppose you have the `jumbotron` content type in your Contentful space. This content type has the
`title` and `content` fields, both strings.

Let's create the `app/components/jumbotron_component.rb` file:

```ruby
class JumbotronComponent < Renderful::Component
  def render
    <<~HTML
      <div class="jumbotron">
        <h1 class="display-4">#{ entry.title }</h1>
        <p class="lead">#{ entry.content }</p>
      </div>
    HTML
  end
end
```

You can now render the component like this:

```ruby
RenderfulClient.render('my_entry_id')
```

### Caching

You can easily cache the output of your components. A Redis cache implementation is included out of
the box. Here's an example:

```ruby
RenderfulClient = Renderful.new(
  cache: Renderful::Cache::Redis.new(Redis.new(url: 'redis://localhost:6379')),
  # ...
)
```

If you are using Rails and want to use the Rails cache store for Renderful, you can simply pass
`Rails.cache`, which responds to the expected interface:

```ruby
RenderfulClient = Renderful.new(ful,
  cache: Rails.cache,
  # ...
)
```

#### Cache invalidation

The best way to invalidate the cache is through [webhooks](https://www.contentful.com/developers/docs/concepts/webhooks/).

Renderful ships with a framework-agnostic webhook processor you can use to automatically invalidate
the cache for all updated content:

```ruby
RenderfulClient.invalidate_cache_from_webhook(json_body)
```

This is how you could use it in a Rails controller:

```ruby
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    RenderfulClient.invalidate_cache_from_webhook(request.raw_post)
    head :no_content
  end
end
```

The cache invalidator will not only invalidate the cache for the entry that has been updated, but
also for any entries linking to it, so that they are re-rendered. This is very useful, for instance,
if you have a `Page` entry type that contains references to many UI components - when one of the
components is updated, you want the page to be re-rendered.

### ViewComponent support

Renderful integrates nicely with [ViewComponent](https://github.com/github/view_component) for
rendering your components:

```ruby
RenderfulClient = Renderful::Client.new(
  components: {
    'jumbotron' => JumbotronComponent, # JumbotronComponent inherits from ViewComponent::Base
  },
)
``` 

However, keep in mind you will now have to pass a view context when rendering them:

```ruby
RenderfulClient.render('my_entry_id', view_context: view_context)
```

## Providers

### Contentful

In order to integrate with Contentful, you will first need to add the `contentful` gem to your
Gemfile:

```ruby
gem 'contentful'
```

Now make sure to install it:

```console
$ bundle install
```

Finally, initialize Renderful with the Contentful provider:

```ruby
RenderfulClient = Renderful::Client.new(
  provider: Renderful::Provider::Contentful.new(
    contentful: Contentful::Client.new(
      space: 'cfexampleapi',
      access_token: 'b4c0n73n7fu1',
    )
  )
)
```

You can now render your Contentful entries via Renderful:

```ruby
RenderfulClient.render('your_entry_id')
```

### Prismic

In order to integrate with Prismic, you will first need to add the `prismic.io` gem to your Gemfile:

```ruby
gem 'prismic.io', require: 'prismic'
```

Now make sure to install it:

```console
$ bundle install
```

Finally, initialize Renderful with the Prismic provider:

```ruby
RenderfulClient = Renderful::Client.new(
  provider: Renderful::Provider::Prismic.new(
    prismic: Prismic.api('https://yourendpoint.prismic.io/api', 'your_access_token')
  )
)
```

You can now render your Prismic documents via Renderful:

```ruby
RenderfulClient.render('your_entry_id')
```

NOTE: Due to limitations in Prismic's API, cache invalidation for Prismic will invalidate all your
components. Depending on how often you update your content, you may want to disable caching entirely
if you are using Prismic.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run
the tests. You can also run `bin/console` for an interactive prompt that will allow you to
experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new
version, update the version number in `version.rb`, and then run `bundle exec rake release`, which
will create a git tag for the version, push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nebulab/renderful.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

Renderful was originally developed by [Nebulab](https://nebulab.it) and sponsored by
[Bolt Threads](https://www.boltthreads.com). It is currently maintained by Nebulab.
