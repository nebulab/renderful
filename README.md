# Renderful

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
    'jumbotron' => contentful
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

#### renderer and client

You also get access to the `Renderful::Render` and `Renderful::Client` objects, which is useful for
instance if you need to render resolved fields as in our `Grid` example:

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

Bug reports and pull requests are welcome on GitHub at https://github.com/bestmadeco/bmc_renderful.
