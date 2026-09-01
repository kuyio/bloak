# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in bloak.gemspec.
gemspec

gem "dandruff", github: "kuyio/dandruff"

group :development do
  gem 'pg'
  gem 'puma'

  gem "kuyio-rubocop", github: "kuyio/kuyio-rubocop"

  # Asset compilation (bin/build_assets) — require: false to avoid
  # loading at boot; only the build script uses these.
  gem "bootstrap", "~> 5.2", require: false
  gem "jquery-rails", "~> 4.4", require: false
  gem "sassc", "~> 2.4", require: false
  gem "sprockets-rails", ">= 3.4"
end

# To use a debugger
# gem 'byebug', group: [:development, :test]
