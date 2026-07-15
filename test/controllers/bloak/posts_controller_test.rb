# frozen_string_literal: true

require "test_helper"

module Bloak
  class PostsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @post = bloak_posts(:published_post)
      attach_test_image(@post)

      @featured = bloak_posts(:featured_post)
      attach_test_image(@featured)

      @draft = bloak_posts(:draft_post)
      attach_test_image(@draft)

      @guide = bloak_posts(:another_topic_post)
      attach_test_image(@guide)

      @other_author = bloak_posts(:other_author_post)
      attach_test_image(@other_author)
    end

    # --- Index ---

    test "index returns success" do
      get posts_url
      assert_response :success
    end

    test "index shows published posts" do
      get posts_url
      assert_match @post.title, response.body
      assert_match @featured.title, response.body
    end

    test "index does not show draft posts" do
      get posts_url
      assert_no_match @draft.title, response.body
    end

    test "root url renders index" do
      get root_url
      assert_response :success
      assert_match @post.title, response.body
    end

    # --- Show ---

    test "show returns success for published post" do
      get post_url(@post)
      assert_response :success
      assert_match @post.title, response.body
    end

    test "show works with slug" do
      get post_url(@post.slug)
      assert_response :success
      assert_match @post.title, response.body
    end

    test "show returns 404 for nonexistent post" do
      get post_url("nonexistent-slug")
      assert_response :not_found
    end

    # --- Topic ---

    test "topic filters by topic" do
      get topic_url(topic: "tutorials")
      assert_response :success
      assert_match @post.title, response.body
      assert_no_match @guide.title, response.body
    end

    test "topic returns 404 for invalid topic" do
      get topic_url(topic: "nonexistent-topic")
      assert_response :not_found
    end

    # --- Author ---

    test "author filters by author name" do
      get author_url(name: "Jane Doe")
      assert_response :success
      assert_match @post.title, response.body
      assert_no_match @other_author.title, response.body
    end

    test "author returns 404 for unknown author" do
      get author_url(name: "Nobody")
      assert_response :not_found
    end

    # --- Search ---

    test "search returns matching results" do
      post search_url, params: { query: @post.title }
      assert_response :success
      assert_match @post.title, response.body
    end

    test "search does not show non-matching posts" do
      post search_url, params: { query: "zzzznonexistentzzzz" }
      assert_response :success
      assert_no_match @post.title, response.body
    end
  end
end
