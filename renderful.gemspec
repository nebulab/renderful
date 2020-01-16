# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'renderful/version'

Gem::Specification.new do |spec|
  spec.name          = 'renderful'
  spec.version       = Renderful::VERSION
  spec.authors       = ['Alessandro Desantis']
  spec.email         = ['desa.alessandro@gmail.com']

  spec.summary       = 'Render your Contentful space!'
  spec.homepage      = 'https://github.com/nebulab/renderful'
  spec.license       = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/nebulab/renderful'
  spec.metadata['changelog_uri'] = 'https://github.com/nebulab/renderful/blob/master/README.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'contentful', '~> 2.11'
  spec.add_dependency 'rails', ['>= 5.0.0', '< 7']

  spec.add_development_dependency 'appraisal', '~> 2.2'
  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'combustion', '~> 1.1'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'redis', '~> 4.1'
  spec.add_development_dependency 'rspec-rails', '~> 4.0.0.beta4'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.4.1'
  spec.add_development_dependency 'rubocop', '~> 0.79.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.37'
end
