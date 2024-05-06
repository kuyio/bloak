require_relative "lib/bloak/version"

Gem::Specification.new do |spec|
  spec.name        = "bloak"
  spec.version     = Bloak::VERSION
  spec.authors     = ["KUY.io Inc."]
  spec.email       = ["info@kuy.io"]
  spec.homepage    = "https://github.com/kuyio/bloak"
  spec.summary     = "Bloak is a markdown blog engine for Ruby on Rails"
  spec.description = "Bloak is a markdown blog engine for Ruby on Rails"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://rubygems.pkg.github.com/kuyio"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/kuyio/bloak"
  spec.metadata["changelog_uri"] = "https://github.com/kuyio/bloak/CHANGELOG.md"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency("rails", ">= 7.0", "< 8.0")
  spec.add_dependency("sprockets-rails", ">= 3.4")
  spec.add_dependency("sass-rails", "~> 6.0")
  spec.add_dependency("bootstrap", "~> 5.2")
  spec.add_dependency("jquery-rails", "~> 4.4")
  spec.add_dependency("turbolinks", "~> 5.2")
  spec.add_dependency("friendly_id", "~> 5.4")
  spec.add_dependency("image_processing", "~> 1.2")
  spec.add_dependency("redcarpet", "~> 3.6")
  spec.add_dependency("rouge", "~> 4.1")
  spec.add_dependency("pg_search", "~> 2.3.5")
  spec.add_dependency("pagy", "~> 8.0")
  spec.add_dependency("meta-tags", "~> 2.17")
end
