source 'https://rubygems.org'

# Declare your gem's dependencies in ghost_in_the_post.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

group :development do
  gem 'guard'
  gem 'guard-rspec'
end

# Added here so it does not show up on the Gemspec; I only want it for CI builds
gem 'coveralls', group: :test, require: nil
