# frozen_string_literal: true

module Bloak
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      desc "Copy Bloak views to your application for customization"

      class_option :scope, type: :string, default: "all",
        desc: "Limit views to copy: all, layout, posts, admin, partials"

      def copy_views
        scope = options[:scope]
        engine_views = Bloak::Engine.root.join("app/views/bloak")
        target = Rails.root.join("app/views/bloak")

        case scope
        when "layout"
          copy_directory "layouts", engine_views, target
        when "posts"
          copy_directory "posts", engine_views, target
        when "admin"
          copy_directory "admin", engine_views, target
        when "partials"
          copy_directory "application", engine_views, target
        else
          copy_all(engine_views, target)
        end
      end

      def show_post_install
        say ""
        say "Views copied successfully!", :green
        say ""
        say "You can now edit the templates in app/views/bloak/"
        say "Rails will use your copies instead of the engine defaults."
        say ""
        say "To theme without editing views, override CSS variables instead:"
        say ""
        say "  :root {"
        say "    --bloak-link: #e63946;"
        say "    --bloak-heading: #1d3557;"
        say "    --bloak-active-tag-bg: #f1faee;"
        say "    --bloak-active-tag-text: #e63946;"
        say "  }"
        say ""
      end

      private

      def copy_all(source, target)
        directories = Dir.children(source).select { |d| File.directory?(source.join(d)) }
        directories.each { |d| copy_directory(d, source, target) }

        # Copy layouts
        engine_layouts = Bloak::Engine.root.join("app/views/layouts/bloak")
        target_layouts = Rails.root.join("app/views/layouts/bloak")
        return unless engine_layouts.exist?

        directory engine_layouts.to_s, target_layouts.to_s
      end

      def copy_directory(subdir, source, target)
        source_dir = source.join(subdir)
        return unless source_dir.exist?

        directory source_dir.to_s, target.join(subdir).to_s
      end
    end
  end
end
