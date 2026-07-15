# frozen_string_literal: true

require "liquid"
require "erb"

module Bloak
  module LiquidTags
    class MediaTag < Liquid::Tag
      def initialize(tag_name, markup, options)
        super
        @name = markup.strip.gsub(/\A["']|["']\z/, "")
      end

      def render(_context)
        name = ERB::Util.html_escape(@name)

        if Bloak::Media.image(@name).present?
          alt = ERB::Util.html_escape(Bloak::Media.image_alt(@name))
          <<~HTML
            <img src="#{Bloak::Media.image_url(@name)}" alt="#{alt}" />
            <p class="fs-7 text-muted text-center mb-5 media-label">#{alt}</p>
          HTML
        else
          <<~HTML
            <p class="bg-danger text-white text-centered p-3 mb-5">
              <span class="icon"><i class="fa fa-exclamation-circle"></i></span>
              Image not found: '#{name}'
            </p>
          HTML
        end
      end
    end

    class TocTag < Liquid::Tag
      def initialize(tag_name, markup, options)
        super
        label = markup.strip.gsub(/\A["']|["']\z/, "")
        @label = label.empty? ? "Table of Contents" : label
      end

      def render(context)
        document = context.registers[:document]
        return "" if document.blank?

        toc_html = MarkdownRenderer.render_toc(document, 2)

        <<~HTML
          <div class="table-of-contents">
            <h2 class="toc-title">#{ERB::Util.html_escape(@label)}</h2>
            #{toc_html}
          </div>
        HTML
      end
    end

    class DangerBlock < Liquid::Block
      def render(context)
        content = super
        <<~HTML
          <blockquote class="alert alert-danger">
          <p class="text-danger">
              <span class="icon text-danger"><i class="fa fa-exclamation-circle"></i></span>
              <strong>Important:</strong> #{content.strip}
            </p>
          </blockquote>
        HTML
      end
    end

    class WarningBlock < Liquid::Block
      def render(context)
        content = super
        <<~HTML
          <blockquote class="alert alert-warning">
            <p class="text-dark">
              <span class="icon text-warning"><i class="fa fa-exclamation-triangle"></i></span>
              <strong>Note:</strong> #{content.strip}
            </p>
          </blockquote>
        HTML
      end
    end

    class InfoBlock < Liquid::Block
      def render(context)
        content = super
        <<~HTML
          <blockquote class="alert alert-info">
          <p class="text-dark">
              <span class="icon text-info"><i class="fa fa-info-circle"></i></span>
              #{content.strip}
            </p>
          </blockquote>
        HTML
      end
    end

    class QuoteBlock < Liquid::Block
      def render(context)
        content = super
        <<~HTML
          <blockquote class="blockquote">
            <p class="text-dark">
              #{content.strip}
            </p>
          </blockquote>
        HTML
      end
    end

    def self.register!
      env = Liquid::Environment.default
      env.register_tag("media", MediaTag)
      env.register_tag("toc", TocTag)
      env.register_tag("danger", DangerBlock)
      env.register_tag("warning", WarningBlock)
      env.register_tag("info", InfoBlock)
      env.register_tag("quote", QuoteBlock)
    end
  end
end

Bloak::LiquidTags.register!
