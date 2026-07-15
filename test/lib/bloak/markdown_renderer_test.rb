# frozen_string_literal: true

require "test_helper"

class MarkdownRendererTest < ActiveSupport::TestCase
  test "renders bold text" do
    html = MarkdownRenderer.md_to_html("**bold**")
    assert_match "<strong>bold</strong>", html
  end

  test "renders italic text" do
    html = MarkdownRenderer.md_to_html("*italic*")
    assert_match "<em>italic</em>", html
  end

  test "renders headings with id and class" do
    html = MarkdownRenderer.md_to_html("## My Heading")
    assert_match '<h2 class="title is-2"', html
    assert_match 'id="my-heading"', html
  end

  test "renders headings with special characters in id" do
    html = MarkdownRenderer.md_to_html("## Hello & World")
    assert_match 'id="hello-amp-world"', html
  end

  test "renders fenced code blocks with syntax highlighting" do
    md = "```ruby\nputs 'hello'\n```"
    html = MarkdownRenderer.md_to_html(md)
    assert_match "highlight", html
    assert_match "ruby", html
  end

  test "renders autolinks" do
    html = MarkdownRenderer.md_to_html("Visit https://example.com")
    assert_match "<a", html
    assert_match "https://example.com", html
  end

  test "renders tables" do
    md = "| A | B |\n|---|---|\n| 1 | 2 |"
    html = MarkdownRenderer.md_to_html(md)
    assert_match "<table>", html
    assert_match "<th>", html
    assert_match "<td>", html
  end

  test "links open in new tab" do
    html = MarkdownRenderer.md_to_html("[link](https://example.com)")
    assert_match 'target="_blank"', html
    assert_match "noopener", html
  end

  test "regular paragraph wraps in p tags" do
    html = MarkdownRenderer.md_to_html("Just a paragraph.")
    assert_match "<p>Just a paragraph.</p>", html
  end

  test "render_toc generates table of contents" do
    md = "## First\n\nContent\n\n## Second\n\nMore content"
    html = MarkdownRenderer.render_toc(md)
    assert_match "First", html
    assert_match "Second", html
  end

  # Liquid tag tests

  test "danger block tag" do
    html = MarkdownRenderer.md_to_html("{% danger %}This is dangerous{% enddanger %}")
    assert_match "alert-danger", html
    assert_match "Important:", html
    assert_match "This is dangerous", html
  end

  test "warning block tag" do
    html = MarkdownRenderer.md_to_html("{% warning %}This is a warning{% endwarning %}")
    assert_match "alert-warning", html
    assert_match "Note:", html
  end

  test "info block tag" do
    html = MarkdownRenderer.md_to_html("{% info %}This is info{% endinfo %}")
    assert_match "alert-info", html
    assert_match "This is info", html
  end

  test "quote block tag" do
    html = MarkdownRenderer.md_to_html("{% quote %}This is a quote{% endquote %}")
    assert_match "blockquote", html
    assert_match "This is a quote", html
  end

  test "media tag with existing image renders img" do
    image = Bloak::Image.new(name: "md-test-image", alt: "Test alt text")
    image.image_file.attach(
      io: File.open(file_fixture("test.png")),
      filename: "test.png",
      content_type: "image/png"
    )
    image.save!
    html = MarkdownRenderer.md_to_html('{% media "md-test-image" %}')
    assert_match "<img", html
    assert_match "Test alt text", html
  end

  test "media tag with missing image renders error" do
    html = MarkdownRenderer.md_to_html('{% media "nonexistent" %}')
    assert_match "Image not found", html
    assert_match "nonexistent", html
  end

  test "media tag prevents XSS via alt text" do
    image = Bloak::Image.new(name: "xss-test", alt: '" onload="alert(1)')
    image.image_file.attach(
      io: File.open(file_fixture("test.png")),
      filename: "test.png",
      content_type: "image/png"
    )
    image.save!
    html = MarkdownRenderer.md_to_html('{% media "xss-test" %}')
    doc = Nokogiri::HTML.fragment(html)
    img = doc.at_css("img")
    assert img, "expected an <img> tag"
    assert_nil img["onload"], "onload attribute must not be present"
    assert_includes img["alt"], "onload", "alt text should contain the literal string"
  end

  test "toc tag renders table of contents" do
    md = "{% toc %}\n\n## Section One\n\nContent\n\n## Section Two\n\nMore"
    html = MarkdownRenderer.md_to_html(md)
    assert_match "table-of-contents", html
    assert_match "Table of Contents", html
  end

  test "toc tag with custom label" do
    md = "{% toc \"My Contents\" %}\n\n## Section One\n\nContent"
    html = MarkdownRenderer.md_to_html(md)
    assert_match "My Contents", html
  end

  test "Liquid variables are interpolated" do
    html = MarkdownRenderer.md_to_html("Hello {{ name }}", { name: "World" })
    assert_match "World", html
  end

  test "Liquid tags in fenced code blocks are not processed" do
    md = "```\n{{ secret }}\n```"
    html = MarkdownRenderer.md_to_html(md, { secret: "LEAKED" })
    assert_no_match "LEAKED", html
  end

  # Sanitization tests

  test "strips script tags from output" do
    html = MarkdownRenderer.md_to_html('<script>alert("xss")</script>Safe text')
    assert_no_match "<script>", html
    assert_match "Safe text", html
  end

  test "strips event handler attributes" do
    html = MarkdownRenderer.md_to_html('<img src="x" onerror="alert(1)">')
    doc = Nokogiri::HTML.fragment(html)
    img = doc.at_css("img")
    assert_nil img&.[]("onerror")
  end

  test "strips iframe tags" do
    html = MarkdownRenderer.md_to_html('<iframe src="https://evil.com"></iframe>')
    assert_no_match "<iframe", html
  end

  test "ERB is not processed by default" do
    html = MarkdownRenderer.md_to_html("<%= 1 + 1 %>")
    assert_no_match "2", html
  end

  # ERB legacy mode tests

  test "ERB is processed when allow_erb_in_posts is true" do
    Bloak.allow_erb_in_posts = true
    html = MarkdownRenderer.md_to_html("<%= 1 + 1 %>")
    assert_match "2", html
  ensure
    Bloak.allow_erb_in_posts = false
  end

  test "ERB assigns work when allow_erb_in_posts is true" do
    Bloak.allow_erb_in_posts = true
    html = MarkdownRenderer.md_to_html("<%= name %>", { name: "World" })
    assert_match "World", html
  ensure
    Bloak.allow_erb_in_posts = false
  end

  test "ERB in fenced code blocks is not processed when allow_erb_in_posts is true" do
    Bloak.allow_erb_in_posts = true
    md = "```\n<%= 1 + 1 %>\n```"
    html = MarkdownRenderer.md_to_html(md)
    assert_match "&lt;%=", html
  ensure
    Bloak.allow_erb_in_posts = false
  end
end
