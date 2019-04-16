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

Once you have installed the gem, you can configure it via the `.configure` method:

```ruby
Renderful.configure do |config|
  config.space = 'CONTENTFUL_SPACE_ID'
  config.access_token = 'CONTENTFUL_ACCESS_TOKEN'
  
  # The `mappings` attribute should be a hash of content type to component class mappings.
  # See below to understand how components should be implemented. 
  config.mappings = {
    'jumbotron' => Components::Jumbotron,
    'banner' => Components::Banner,
    'textBlock' => Components::TextBlock,
  }
end
``` 

(This should go in an initializer in a Rails app, or in its equivalent for your framework.)

## Usage

Suppose you have the `jumbotron` content type in your Contentful space. This content type has the
`title` and `content` fields, both strings.

Let's create the `app/components/jumbotron.rb` file:

```ruby
module Components
  class Jumbotron < Renderful::Entry
  end
end
```

Since we don't need any custom helpers or logic, this will be enough! All that's left to do is to
implement the actual Rails view for our component, which we will put in `app/views/renderful/jumbotron.html.erb`:

```erb
<div class="jumbotron">
  <h1 class="display-4"><%= title %></h1>
  <p class="lead"><%= content %></p>
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
