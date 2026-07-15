# frozen_string_literal: true

require "test_helper"

module Bloak
  class PostTest < ActiveSupport::TestCase
    setup do
      @post = bloak_posts(:published_post)
      attach_test_image(@post)
    end

    # --- Validations ---

    test "valid post with all attributes and image" do
      assert @post.valid?
    end

    test "invalid without title" do
      @post.title = nil
      assert_not @post.valid?
      assert_includes @post.errors[:title], "can't be blank"
    end

    test "invalid without topic" do
      @post.topic = nil
      assert_not @post.valid?
      assert_includes @post.errors[:topic], "can't be blank"
    end

    test "invalid without summary" do
      @post.summary = nil
      assert_not @post.valid?
      assert_includes @post.errors[:summary], "can't be blank"
    end

    test "invalid without content" do
      @post.content = nil
      assert_not @post.valid?
      assert_includes @post.errors[:content], "can't be blank"
    end

    test "invalid without author_name" do
      @post.author_name = nil
      assert_not @post.valid?
      assert_includes @post.errors[:author_name], "can't be blank"
    end

    test "invalid without author_email" do
      @post.author_email = nil
      assert_not @post.valid?
      assert_includes @post.errors[:author_email], "can't be blank"
    end

    test "invalid without cover_image" do
      @post.cover_image.purge
      assert_not @post.valid?
      assert_includes @post.errors[:cover_image], "is required"
    end

    test "invalid with non-image cover_image mime type" do
      @post.cover_image.attach(
        io: File.open(file_fixture("test.gif")),
        filename: "test.gif",
        content_type: "image/gif"
      )
      assert_not @post.valid?
      assert_includes @post.errors[:cover_image], "must be an image"
    end

    # --- Scopes ---

    test "published scope returns only published posts" do
      results = Post.published
      assert results.all?(&:published?)
      assert_not_includes results, bloak_posts(:draft_post)
    end

    test "unpublished scope returns only drafts" do
      results = Post.unpublished
      assert results.none?(&:published?)
      assert_includes results, bloak_posts(:draft_post)
    end

    test "featured scope returns only featured posts" do
      results = Post.featured
      assert results.all?(&:featured?)
      assert_includes results, bloak_posts(:featured_post)
    end

    test "tagged_with scope filters by topic" do
      results = Post.tagged_with("tutorials")
      assert results.all? { |p| p.topic == "tutorials" }
      assert_not_includes results, bloak_posts(:another_topic_post)
    end

    test "authored_by scope filters by author_name" do
      results = Post.authored_by("Jane Doe")
      assert results.all? { |p| p.author_name == "Jane Doe" }
      assert_not_includes results, bloak_posts(:other_author_post)
    end

    # --- FriendlyId ---

    test "generates slug from title" do
      post = Post.new(
        title: "My New Post", topic: "test", summary: "s", content: "c",
        author_name: "a", author_email: "a@b.com"
      )
      attach_test_image(post)
      post.save!
      assert_equal "my-new-post", post.slug
    end

    # --- Callbacks ---

    test "before_save computes reading_time from content" do
      @post.content = ("word " * 500).strip
      @post.save!
      assert @post.reading_time.positive?
      assert @post.reading_time > 1
    end

    # --- Instance methods ---

    test "gravatar returns gravatar url with default size" do
      url = @post.gravatar
      assert_match %r{gravatar\.com/avatar/}, url
      assert_match(/s=32/, url)
    end

    test "gravatar returns gravatar url with custom size" do
      url = @post.gravatar(64)
      assert_match(/s=64/, url)
    end

    test "cover_image_path returns path when attached" do
      assert_not_equal "#", @post.cover_image_path
    end

    test "cover_image_path returns # when not attached" do
      @post.cover_image.purge
      assert_equal "#", @post.cover_image_path
    end

    test "cover_image_url returns # when not attached" do
      @post.cover_image.purge
      assert_equal "#", @post.cover_image_url
    end

    test "cover_image_variant_path returns # when not attached" do
      @post.cover_image.purge
      assert_equal "#", @post.cover_image_variant_path(:thumbnail)
    end

    test "cover_image_variant_url returns # when not attached" do
      @post.cover_image.purge
      assert_equal "#", @post.cover_image_variant_url(resize_to_fill: [100, 100])
    end

    test "render produces html from markdown content" do
      @post.content = "**bold text**"
      html = @post.render
      assert_match "<strong>bold text</strong>", html
    end

    test "render passes assigns to markdown" do
      @post.content = "<%= greeting %>"
      html = @post.render({ greeting: "Hello World" })
      assert_match "Hello World", html
    end

    test "render_toc produces table of contents" do
      @post.content = "## First Section\n\nContent\n\n## Second Section\n\nMore"
      html = @post.render_toc
      assert_match "First Section", html
      assert_match "Second Section", html
    end
  end
end
