module Bloak
  class Engine < ::Rails::Engine
    require 'jquery-rails'
    require 'pg_search'
    require 'pagy'
    isolate_namespace Bloak

    initializer "engine_name.assets.precompile" do |app|
      app.config.assets.precompile << "bloak_manifest.js"
    end

    config.to_prepare do
      Dir.glob(Rails.root + "app/decorators/**/*_decorator*.rb").each do |c|
        require_dependency(c)
      end
    end
  end
end
