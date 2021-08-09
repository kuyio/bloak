require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'

module MarkdownRenderer
  # Our own custom renderer
  class CustomHTML < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet

    def initialize(extensions = {})
      @locals = extensions.fetch(:locals, {})
      super(extensions)
    end

    def preprocess(document)
      @document = document
      chunks = []
      document.each_line('', chomp: true) do |chunk|
        rendered_chunk =
          if chunk.start_with?('```')
            chunk
          else
            ERB.new(chunk).result_with_hash(@locals)
          end
        chunks << rendered_chunk
      end

      chunks.join("\n")
    end

    def header(text, level)
      stripped = text.downcase.gsub(/[^0-9a-z]/i, '-').delete_suffix('-')
      %(<h1 class="title is-#{level} mt-5" id="#{stripped}">#{text}</h1>)
    end

    def paragraph(text)
      process_custom_tags(text)
    end

    def rouge_formatter(lexer)
      Rouge::Formatters::HTMLLegacy.new(css_class: "highlight #{lexer.tag}")
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
      elsif t = text.match(/(!toc)(\[(.+)\])?/)
          table_of_contents(t[2]&.strip)
      else
        %(<p>#{text}</p>)
      end
    end

    def quote_box(content)
      result = <<~HTML
        <blockquote class="alert alert-secondary">
          <p class="text-dark">
            #{content}
          </p>
        </blockquote>
      HTML
      result
    end

    def info_box(content)
      result = <<~HTML
        <blockquote class="alert alert-info">
        <p class="text-dark">
            <span class="icon text-info"><i class="fa fa-info-circle"></i></span>
            #{content}
          </p>
        </blockquote>
      HTML
      result
    end

    def warning_box(content)
      result = <<~HTML
        <blockquote class="alert alert-warning">
          <p class="text-dark">
            <span class="icon text-warning"><i class="fa fa-exclamation-triangle"></i></span>
            <strong>Note:</strong> #{content.strip}
          </p>
        </blockquote>
      HTML
      result
    end

    def danger_box(content)
      result = <<~HTML
        <blockquote class="alert alert-danger">
        <p class="text-danger">
            <span class="icon text-danger"><i class="fa fa-exclamation-circle"></i></span>
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

    def table_of_contents(label)
      label = "Table of Contents" if label.blank?
      toc_render = Redcarpet::Render::HTML_TOC.new(nesting_level: 2..2)
      parser     = Redcarpet::Markdown.new(toc_render)

      <<~HTML
        <div class="table-of-contents">
          <h2 class="toc-title">#{label}</h2>
          #{parser.render(@document)}
        </div>
      HTML
    end
  end

  def self.md_to_html(content, assigns = {})
    # Render the result via Redcarpet, using our Custom Renderer
    Redcarpet::Markdown.new(
      CustomHTML.new(
        link_attributes: { target: '_blank', rel: 'noopener' },
        locals: assigns
      ),
      fenced_code_blocks: true,
      autolink: true,
      superscript: true,
      no_intra_emphasis: true,
      space_after_headers: false,
      highlight: true,
      with_toc_data: true
    ).render(content).html_safe
  end
end
