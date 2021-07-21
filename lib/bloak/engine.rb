module Bloak
  class Engine < ::Rails::Engine
    require 'jquery-rails'
    require 'pg_search'
    require 'pagy'
    isolate_namespace Bloak

    initializer "engine_name.assets.precompile" do |app|
      app.config.assets.precompile << "bloak_manifest.js"
    end
  end
end
