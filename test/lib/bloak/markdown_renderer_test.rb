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

  test "danger box custom tag" do
    html = MarkdownRenderer.md_to_html("!!This is dangerous")
    assert_match "alert-danger", html
    assert_match "Important:", html
    assert_match "This is dangerous", html
  end

  test "warning box custom tag" do
    html = MarkdownRenderer.md_to_html("!wThis is a warning")
    assert_match "alert-warning", html
    assert_match "Note:", html
  end

  test "info box custom tag" do
    html = MarkdownRenderer.md_to_html("!iThis is info")
    assert_match "alert-info", html
    assert_match "This is info", html
  end

  test "quote box custom tag" do
    html = MarkdownRenderer.md_to_html("!qThis is a quote")
    assert_match "blockquote", html
    assert_match "This is a quote", html
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

  test "ERB in content is processed" do
    html = MarkdownRenderer.md_to_html("<%= 1 + 1 %>")
    assert_match "2", html
  end

  test "ERB in fenced code blocks is not processed" do
    md = "```\n<%= 1 + 1 %>\n```"
    html = MarkdownRenderer.md_to_html(md)
    assert_match "&lt;%=", html
  end

  test "assigns are available in ERB" do
    html = MarkdownRenderer.md_to_html("<%= name %>", { name: "World" })
    assert_match "World", html
  end

  test "media tag with existing image renders img" do
    image = Bloak::Image.new(name: "md-test-image", alt: "Test alt text")
    image.image_file.attach(
      io: File.open(file_fixture("test.png")),
      filename: "test.png",
      content_type: "image/png"
    )
    image.save!
    html = MarkdownRenderer.md_to_html("!media[md-test-image]")
    assert_match "<img", html
    assert_match "Test alt text", html
  end

  test "media tag with missing image renders error" do
    html = MarkdownRenderer.md_to_html("!media[nonexistent]")
    assert_match "Image not found", html
    assert_match "nonexistent", html
  end

  test "toc custom tag renders table of contents" do
    md = "!toc\n\n## Section One\n\nContent\n\n## Section Two\n\nMore"
    html = MarkdownRenderer.md_to_html(md)
    assert_match "table-of-contents", html
    assert_match "Table of Contents", html
  end

  test "toc custom tag with custom label" do
    md = "!toc[My Contents]\n\n## Section One\n\nContent"
    html = MarkdownRenderer.md_to_html(md)
    assert_match "My Contents", html
  end
end
