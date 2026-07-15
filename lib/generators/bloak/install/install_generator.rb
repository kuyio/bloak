# frozen_string_literal: true

module Bloak
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Install Bloak: create initializer, mount routes, and run migrations"

      def copy_initializer
        template "initializer.rb", "config/initializers/bloak.rb"
      end

      def mount_engine
        route 'mount Bloak::Engine => "/blog"'
      end

      def install_migrations
        rake "bloak:install:migrations"
      end

      def run_migrations
        rake "db:migrate"
      end

      def show_post_install
        say ""
        say "Bloak installed successfully!", :green
        say ""
        say "Next steps:"
        say "  1. Edit config/initializers/bloak.rb with your settings"
        say "  2. Run `rails generate bloak:views` to customize templates"
        say "  3. Override CSS variables in your stylesheet to theme the blog"
        say ""
        say "Visit /blog to see your blog!"
        say ""
      end
    end
  end
end
