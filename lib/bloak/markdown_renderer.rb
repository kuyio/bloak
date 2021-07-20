require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'

module MarkdownRenderer
  # Our own custom renderer
  class CustomHTML < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet

    def header(text, level)
      %(<h1 class="title is-#{level} mt-5">#{text}</h1>)
    end

    def paragraph(text)
      process_custom_tags(text)
    end

    private

    def process_custom_tags(text)
      # Our own custom tags
      if t = text.match(/(!!)(.+)/)
        danger_box(t[2])
      elsif t = text.match(/(!w)(.+)/)
          warning_box(t[2])
      elsif t = text.match(/(!i)(.+)/)
          info_box(t[2])
      elsif t = text.match(/(!q)(.+)/)
          quote_box(t[2])
      elsif t = text.match(/(!media)\[(.+)\]/)
          media_tag(t[2].strip)
      else
        %(<p>#{text}</p>)
      end
    end

    def quote_box(content)
      result = <<~HTML
        <blockquote class="has-background-white-dark">
          <p>
            #{content}
          </p>
        </blockquote>
      HTML
      result
    end

    def info_box(content)
      result = <<~HTML
        <blockquote class="has-background-info-light">
          <p>
            <span class="icon has-text-info"><i class="fa fa-info-circle"></i></span>
            #{content}
          </p>
        </blockquote>
      HTML
      result
    end

    def warning_box(content)
      result = <<~HTML
        <blockquote class="has-background-warning-light">
          <p>
            <span class="icon has-text-warning"><i class="fa fa-exclamation-triangle"></i></span>
            <strong>Note:</strong> #{content.strip}
          </p>
        </blockquote>
      HTML
      result
    end

    def danger_box(content)
      result = <<~HTML
        <blockquote class="has-background-danger-light">
          <p>
            <span class="icon has-text-danger"><i class="fa fa-exclamation-circle"></i></span>
            <strong>Important:</strong> #{content}
          </p>
        </blockquote>
      HTML
      result
    end

    def media_tag(name)
      result = if Bloak::Media.image(name).present?
        <<~HTML
          <img src="#{Bloak::Media.image_url(name)}" alt="#{Bloak::Media.image_alt(name)}" />
          <p class="fs-7 text-muted text-center mb-5">#{Bloak::Media.image_alt(name)}</p>
        HTML
      else
        <<~HTML
          <p class="bg-danger text-white text-centered p-3 mb-5">
            <span class="icon"><i class="fa fa-exclamation-circle"></i></span>
            Image not found: '#{name}'
          </p>
        HTML
      end

      result
    end
  end

  def self.md_to_html(content, assigns = {})
    # Render any embedded Ruby (ERB) code to HTML fragments
    src = ApplicationController.render(inline: content, assigns: assigns)

    # Render the result via Redcarpet, using our Custom Renderer
    Redcarpet::Markdown.new(
      CustomHTML.new(link_attributes: {target: '_blank'}),
      fenced_code_blocks: true,
      autolink: true,
      superscript: true,
      no_intra_emphasis: true,
      space_after_headers: false,
      highlight: true,
    ).render(src).html_safe
  end
end
