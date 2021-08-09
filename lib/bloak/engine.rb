require "friendly_id"
require 'bootstrap'
require 'jquery-rails'
require 'turbolinks'
require 'pg_search'
require 'pagy'
require 'meta-tags'

require "bloak/nlp"
require "bloak/markdown_renderer"
require "bloak/media"

module Bloak
  class Engine < ::Rails::Engine
    isolate_namespace Bloak

    @@stylesheets = []
    @@javascripts = []

    initializer "engine_name.assets.precompile" do |app|
      app.config.assets.precompile += [
        "bloak_manifest.js",
        "bloak/application.js",
        "bloak/application.scss"
      ]
    end

    config.to_prepare do
      Dir.glob(Rails.root + "app/decorators/**/*_decorator*.rb").each do |c|
        require_dependency(c)
      end
    end

    def self.add_javascript(script)
      @@javascripts << script
    end

    def self.add_stylesheet(stylesheet)
      @@stylesheets << stylesheet
    end

    def self.javascripts
      @@javascripts
    end

    def self.stylesheets
      @@stylesheets
    end

    add_javascript('bloak/application')
    add_stylesheet('bloak/application')
  end
end
