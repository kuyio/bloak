# frozen_string_literal: true

require "commonmarker"
require "rouge"
require "liquid"
require "dandruff"
require "nokogiri"

module MarkdownRenderer
  COMMONMARKER_OPTIONS = {
    parse: { smart: true },
    render: { hardbreaks: false, unsafe: true, escape: false },
    extension: {
      table: true,
      autolink: true,
      superscript: true,
      header_ids: "",
      strikethrough: true,
      tagfilter: false
    }
  }.freeze
  private_constant :COMMONMARKER_OPTIONS

  def self.md_to_html(content, assigns = {})
    processed = preprocess(content, assigns)

    raw_html = Commonmarker.to_html(processed.encode("UTF-8"), options: COMMONMARKER_OPTIONS, plugins: {
      syntax_highlighter: nil
    })

    post_processed = post_process(raw_html)
    sanitize_html(post_processed).html_safe # rubocop:disable Rails/OutputSafety
  end

  def self.render_toc(content, depth = 2)
    doc = Commonmarker.parse(content, options: COMMONMARKER_OPTIONS)
    entries = []

    doc.walk do |node|
      next unless node.type == :heading
      next unless node.header_level.between?(1, depth)

      text = collect_text(node)
      slug = slugify(text)
      entries << { level: node.header_level, text: text, id: slug }
    end

    return "".html_safe if entries.empty?

    toc = entries.map { |e| %(<li><a href="##{e[:id]}">#{ERB::Util.html_escape(e[:text])}</a></li>) }
    %(<ul>\n#{toc.join("\n")}\n</ul>).html_safe # rubocop:disable Rails/OutputSafety
  end

  def self.post_process(html)
    doc = Nokogiri::HTML.fragment(html)

    doc.css("a[href]").each do |link|
      next if link["href"]&.start_with?("#")

      link["target"] = "_blank"
      link["rel"] = "noopener noreferrer nofollow"
    end

    doc.css("h1, h2, h3, h4, h5, h6").each do |heading|
      level = heading.name.delete_prefix("h")
      heading["class"] = "title is-#{level}"
    end

    doc.css("pre[lang]").each do |pre_node|
      lang = pre_node["lang"]
      next if lang.nil? || lang.empty?

      code_node = pre_node.at_css("code") || pre_node
      highlight_code(pre_node, code_node, lang)
    end

    doc.to_html
  end

  def self.highlight_code(pre_node, code_node, lang)
    lexer = Rouge::Lexer.find(lang) || Rouge::Lexers::PlainText.new
    formatter = Rouge::Formatters::HTML.new
    source = code_node.inner_text

    highlighted = formatter.format(lexer.lex(source))
    code_node.inner_html = highlighted
    code_node["class"] = "highlight #{lexer.tag}"
    pre_node.remove_attribute("lang")
    pre_node["class"] = "highlight #{lexer.tag}"
  end

  def self.collect_text(node)
    text = ""
    node.each do |child|
      text += if child.type == :text || child.type == :code
                child.string_content
              else
                collect_text(child)
              end
    end
    text
  end

  def self.slugify(text)
    text.downcase.gsub(/[^0-9a-z]/i, "-").squeeze("-").delete_prefix("-").delete_suffix("-")
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

  SANITIZER = Dandruff.new do |config|
    config.allowed_tags = %w[
      h1 h2 h3 h4 h5 h6
      p br hr
      strong em sup sub del
      a img
      ul ol li
      blockquote pre code
      table thead tbody tfoot tr th td
      div span i
      input
    ]
    config.allowed_attributes_per_tag = {
      "h1" => %w[id class], "h2" => %w[id class], "h3" => %w[id class],
      "h4" => %w[id class], "h5" => %w[id class], "h6" => %w[id class],
      "a" => %w[href target rel class aria-label],
      "img" => %w[src alt class],
      "pre" => %w[class],
      "code" => %w[class],
      "div" => %w[class],
      "span" => %w[class],
      "blockquote" => %w[class],
      "p" => %w[class],
      "i" => %w[class],
      "tr" => %w[class],
      "td" => %w[colspan rowspan class],
      "th" => %w[colspan rowspan scope class],
      "input" => %w[type checked disabled]
    }
    config.allow_data_attributes = true
    config.allow_aria_attributes = true
    config.allow_data_uri = false
  end
  private_constant :SANITIZER

  def self.sanitize_html(html)
    placeholders = {}
    protected = html.gsub(%r{<pre[\s>].*?</pre>}m) do |match|
      key = "BLOAKPRE#{placeholders.size}BLOAKPRE"
      placeholders[key] = match
      key
    end

    sanitized = SANITIZER.scrub(protected)
    placeholders.each { |key, block| sanitized.sub!(key, block) }
    sanitized
  end

  private_class_method :preprocess, :process_liquid, :process_erb, :chunk_code_blocks,
    :sanitize_html, :post_process, :highlight_code, :collect_text, :slugify
end
