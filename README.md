# Renderful

[![CircleCI](https://circleci.com/gh/bestmadeco/renderful.svg?style=svg)](https://circleci.com/gh/bestmadeco/renderful)

Welcome! Renderful is a rendering engine for [Contentful](https://www.contentful.com) spaces. It
allows you to map your content types to Ruby objects that take care of rendering your content.

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
contentful = Contentful::Client.new(
  space: 'CONTENTFUL_SPACE_ID',
  access_token: 'CONTENTFUL_ACCESS_TOKEN',
)

renderful = Renderful.new(
  contentful: contentful,
  renderers: {
    'jumbotron' => JumbotronRenderer,
  }
)
``` 

## Usage

Suppose you have the `jumbotron` content type in your Contentful space. This content type has the
`title` and `content` fields, both strings.

Let's create the `app/renderers/jumbotron_renderer.rb` file:

```ruby
class JumbotronRenderer < Renderful::Renderer
  def render
    <<~HTML
      <div class="jumbotron">
        <h1 class="display-4"><%= entry.title %></h1>
        <p class="lead"><%= entry.content %></p>
      </div>
    HTML
  end
end
```

You can now render this component by retrieving it from Contentful and rendering it with Renderful:

```ruby
entry = contentful.entry('jumbotron_entry_id')
renderful.render(entry)
```

### Rich text rendering

If you have rich-text fields, you can leverage Contentful's [rich_text_renderer](https://github.com/contentful/rich-text-renderer.rb)
along with a custom local variable:

```ruby
class TextBlockRenderer < Renderful::Renderer::Rails
  def html_body
    RichTextRenderer::Renderer.new.render(entry.body)
  end

  def locals
    { html_body: html_body }
  end
end
```

Then, just reference the `html_body` variable as usual:

```erb
<%# app/views/renderful/_text_block.html.erb %>
<%= raw html_body %>
```

### Nested components

What if you want to have a `Grid` component that can contain references to other components? It's
actually quite simple! Simply create a _References_ field for your content, then recursively render
all of the content entries contained in that field:

```ruby
# app/components/grid.rb
class Grid < Renderful::Renderer
  # This will define a `resolved_blocks` method that reads external references 
  # from the `blocks` fields and turns them into Contentful::Entry instances
  resolve :blocks

  def render
    entries = blocks.map do |block|
      # `client` can be used to access the Renderful::Client instance
      <<~HTML
        <div class="grid-entry">
          #{client.render(block)}
        </div>
      HTML
    end

    <<~HTML
      <div class="grid">#{entries}</div>
    HTML
  end
end
```

### Caching

You can easily cache the output of your renderers by passing a `cache` key when instantiating the
client. The value of this key should be an object that responds to the following methods:
 
- `#read(key)`
- `#write(key, value)`
- `#delete(key)`
- `#exist?(key)`

A Redis cache implementation is included out of the box. Here's an example:

```ruby
renderful = Renderful.new(
  contentful: contentful,
  cache: Renderful::Cache::Redis.new(Redis.new(url: 'redis://localhost:6379')),
  renderers: {
    'jumbotron' => JumbotronRenderer
  }
)
``` 

If you are using Rails and want to use the Rails cache store for Renderful, you can simply pass
`Rails.cache`, which responds to the expected interface:

```ruby
renderful = Renderful.new(
  contentful: contentful,
  cache: Rails.cache,
  renderers: {
    'jumbotron' => JumbotronRenderer
  }
)
``` 

#### Cache invalidation

The best way to invalidate the cache is through [Contentful webhooks](https://www.contentful.com/developers/docs/concepts/webhooks/).

Renderful ships with a framework-agnostic webhook processor you can use to automatically invalidate
the cache for all updated content:

```ruby
Renderful::CacheInvalidator.new(renderful).process_webhook(json_body)
```

This is how you could use it in a Rails controller:

```ruby
class ContentfulWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    Renderful::CacheInvalidator.new(RenderfulClient).process_webhook(request.raw_post)
    head :no_content
  end
end
```

The cache invalidator will not only invalidate the cache for the entry that has been updated, but
also for any entries linking to it, so that they are re-rendered. This is very useful, for instance,
if you have a `Page` entry type that contains references to many UI components - when one of the
components is updated, you want the page to be re-rendered.

### Rails integration

If you are using Ruby on Rails and you want to use ERB instead of including HTML in your renderers,
you can inherit from the Rails renderer:

```ruby
class JumbotronRenderer < Renderful::Renderer::Rails
end
```

Then, create an `app/views/renderful/_jumbotron.html.erb` partial:

```erb
<div class="jumbotron">
  <h1 class="display-4"><%= entry.title %></h1>
  <p class="lead"><%= entry.content %></p>
</div>
```

As you can see, you can access the Contentful entry via the `entry` local variable.

#### Custom renderer

The Rails renderer uses `ActionController::Base.renderer` by default, but this prevents you from
using your own helpers in components. If you want to use a different renderer instead, you can
override the `renderer` method:

```ruby
class JumbotronRenderer < Renderful::Renderer::Rails
  def renderer
    ApplicationController.renderer
  end
end
``` 

#### Custom locals

If you want, you can also add your own locals:

```ruby
class JumbotronRenderer < Renderful::Renderer::Rails
  def locals
    italian_title = entry.title.gsub(/hello/, 'ciao')
    { italian_title: italian_title }
  end
end
```

You would then access them like regular locals:

```erb
<div class="jumbotron">
  <h1 class="display-4">
    <%= entry.title %>
    (<%= italian_title %>) 
  </h1>
  <p class="lead"><%= entry.content %></p>
</div>
```

#### Resolution in ERB views

If you need to render resolved fields (as in our `Grid` example), you can use `renderer` and
`client` to access the `Renderful::Renderer` and `Renderful::Client` objects:

```erb
<%# app/views/renderful/_grid.html.erb %>
<div class="grid">
  <% renderer.blocks.each do |block| %>
    <div class="grid-entry">
      <%= client.render(block) %>
    </div>
  <% end %>
</div>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run 
the tests. You can also run `bin/console` for an interactive prompt that will allow you to 
experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new 
version, update the version number in `version.rb`, and then run `bundle exec rake release`, which 
will create a git tag for the version, push git commits and tags, and push the `.gem` file to 
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bestmadeco/renderful.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

Renderful is sponsored and maintained by [Bolt Threads Inc.](https://www.boltthreads.com).
