# frozen_string_literal: true

require "friendly_id"
require 'pg_search'
require 'pagy'
require 'meta-tags'

require "bloak/nlp"
require "bloak/liquid_tags"
require "bloak/markdown_renderer"
require "bloak/media"

module Bloak
  class Engine < ::Rails::Engine
    isolate_namespace Bloak

    # rubocop:disable Style/ClassVars
    @@stylesheets = []
    @@javascripts = []
    # rubocop:enable Style/ClassVars

    initializer "bloak.migrations" do |app|
      unless defined?(ENGINE_ROOT) && ENGINE_ROOT == root.to_s
        config.paths["db/migrate"].expanded.each do |path|
          app.config.paths["db/migrate"] << path
        end
      end
    end

    initializer "bloak.assets" do |app|
      next unless app.config.respond_to?(:assets)

      app.config.assets.paths << root.join("app", "assets", "fonts")

      if defined?(Sprockets)
        app.config.assets.precompile += %w[
          bloak/application.css
          bloak/application.js
          bloak/fa-brands-400.woff2
          bloak/fa-regular-400.woff2
          bloak/fa-solid-900.woff2
          favicon.png
          logo.png
          check.svg
        ]
      end
    end

    config.to_prepare do
      Rails.root.glob("app/decorators/**/*_decorator*.rb").each do |c|
        load(c)
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
