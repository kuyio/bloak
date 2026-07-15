# frozen_string_literal: true

require "test_helper"

module Bloak
  module Admin
    class PostsControllerTest < ActionDispatch::IntegrationTest
      include Engine.routes.url_helpers

      setup do
        @post = bloak_posts(:published_post)
        attach_test_image(@post)

        Bloak::Post.where.not(id: @post.id).find_each { |p| attach_test_image(p) }
      end

      # --- Auth ---

      test "index requires authentication" do
        get admin_posts_url
        assert_response :unauthorized
      end

      test "index succeeds with valid credentials" do
        get admin_posts_url, headers: { "Authorization" => admin_credentials }
        assert_response :success
      end

      # --- Admin root ---

      test "admin root redirects to posts" do
        get admin_admin_url, headers: { "Authorization" => admin_credentials }
        assert_redirected_to admin_posts_url
      end

      # --- CRUD ---

      test "new renders form" do
        get new_admin_post_url, headers: { "Authorization" => admin_credentials }
        assert_response :success
      end

      test "create with valid params" do
        assert_difference("Post.count") do
          post admin_posts_url,
            headers: { "Authorization" => admin_credentials },
            params: { post: {
              title: "Brand New Post", topic: "test", summary: "summary",
              content: "content", author_name: "Author", author_email: "a@b.com",
              cover_image: fixture_file_upload("test.png", "image/png")
            } }
        end
        assert_redirected_to admin_posts_url
      end

      test "create with invalid params does not create post" do
        assert_no_difference("Post.count") do
          post admin_posts_url,
            headers: { "Authorization" => admin_credentials },
            params: { post: { title: "", topic: "" } }
        end
        assert_response :success
      end

      test "edit renders form" do
        get edit_admin_post_url(@post), headers: { "Authorization" => admin_credentials }
        assert_response :success
      end

      test "update renders edit on save" do
        patch admin_post_url(@post),
          headers: { "Authorization" => admin_credentials },
          params: { post: { title: "Updated Title" } }
        assert_response :success
        @post.reload
        assert_equal "Updated Title", @post.title
      end

      test "update with save and close redirects" do
        patch admin_post_url(@post),
          headers: { "Authorization" => admin_credentials },
          params: { post: { title: "Closed Title" }, commit: "Save and Close" }
        assert_redirected_to admin_posts_url
      end

      test "update with invalid params renders edit" do
        patch admin_post_url(@post),
          headers: { "Authorization" => admin_credentials },
          params: { post: { title: "" } }
        assert_response :success
        @post.reload
        assert_not_equal "", @post.title
      end

      test "destroy removes post" do
        assert_difference("Post.count", -1) do
          delete admin_post_url(@post), headers: { "Authorization" => admin_credentials }
        end
        assert_redirected_to admin_posts_url
      end

      # --- Show (markdown export) ---

      test "show downloads markdown file" do
        get admin_post_url(@post), headers: { "Authorization" => admin_credentials }
        assert_response :success
        assert_match "text/plain", response.content_type
        assert_match @post.slug, response.headers["Content-Disposition"]
      end

      # --- Toggle actions ---

      test "toggle_featured flips featured flag" do
        original = @post.featured?
        patch toggle_featured_admin_post_url(@post), headers: { "Authorization" => admin_credentials }
        @post.reload
        assert_equal !original, @post.featured?
      end

      test "toggle_published flips published flag" do
        original = @post.published?
        patch toggle_published_admin_post_url(@post), headers: { "Authorization" => admin_credentials }
        @post.reload
        assert_equal !original, @post.published?
      end

      # --- Search ---

      test "search with query returns matching results" do
        post admin_posts_search_url,
          headers: { "Authorization" => admin_credentials },
          params: { query: @post.title }
        assert_response :success
        assert_match @post.title, response.body
      end

      test "search with blank query returns all posts" do
        post admin_posts_search_url,
          headers: { "Authorization" => admin_credentials },
          params: { query: "" }
        assert_response :success
      end
    end
  end
end
