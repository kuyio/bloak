# frozen_string_literal: true

require "redcarpet"
require "rouge"
require "rouge/plugins/redcarpet"
require "liquid"

module MarkdownRenderer
  class CustomHTML < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet
    include ActionView::Helpers::SanitizeHelper

    def header(text, level)
      stripped =
        sanitize(text)
          .downcase
          .gsub(/[^0-9a-z]/i, "-").squeeze("-")
          .delete_suffix("-")

      %(<h#{level} class="title is-#{level}" id="#{stripped}">#{text}</h#{level}>)
    end

    def rouge_formatter(lexer)
      Rouge::Formatters::HTMLLegacy.new(css_class: "highlight #{lexer.tag}")
    end
  end

  def self.md_to_html(content, assigns = {})
    processed = preprocess(content, assigns)

    Redcarpet::Markdown.new(
      CustomHTML.new(
        link_attributes: { target: "_blank", rel: "noopener noreferrer nofollow" }
      ),
      fenced_code_blocks: true,
      autolink: true,
      superscript: true,
      no_intra_emphasis: true,
      space_after_headers: false,
      highlight: true,
      with_toc_data: true,
      tables: true
    ).render(processed).html_safe # rubocop:disable Rails/OutputSafety
  end

  def self.render_toc(content, depth = 2)
    toc_render = Redcarpet::Render::HTML_TOC.new(nesting_level: 1..depth)
    parser = Redcarpet::Markdown.new(toc_render)
    parser.render(content).html_safe # rubocop:disable Rails/OutputSafety
  end

  def self.preprocess(content, assigns = {})
    if Bloak.allow_erb_in_posts
      process_erb(content, assigns)
    else
      process_liquid(content, assigns)
    end
  end

  def self.process_liquid(content, assigns = {})
    chunks = chunk_code_blocks(content)
    placeholder_map = {}

    protected_content = chunks.map do |chunk|
      if chunk.start_with?("```")
        key = "BLOAKCODE#{placeholder_map.size}BLOAKCODE"
        placeholder_map[key] = chunk
        key
      else
        chunk
      end
    end.join("\n")

    template = Liquid::Template.parse(protected_content)
    rendered = template.render(
      assigns.transform_keys(&:to_s),
      registers: { document: content }
    )

    placeholder_map.each { |key, code| rendered.sub!(key, code) }
    rendered
  end

  def self.process_erb(content, assigns = {})
    chunks = chunk_code_blocks(content)
    chunks.map do |chunk|
      if chunk.start_with?("```")
        chunk
      else
        ERB.new(chunk).result_with_hash(assigns)
      end
    end.join("\n")
  end

  def self.chunk_code_blocks(text)
    chunks = []
    chunk = []
    in_block = false

    lines = text.lines.reverse
    until lines.empty?
      line = lines.pop

      if line.start_with?("```")
        if in_block
          in_block = false
          chunk << line
          chunks << chunk.join
          chunk = []
        else
          in_block = true
          chunks << chunk.join
          chunk = []
          chunk << line
        end
      else
        chunk << line
      end
    end
    chunks << chunk.join
    chunks
  end

  private_class_method :preprocess, :process_liquid, :process_erb, :chunk_code_blocks
end
