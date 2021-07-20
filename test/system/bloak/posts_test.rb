require "application_system_test_case"

module Bloak
  class PostsTest < ApplicationSystemTestCase
    setup do
      @post = bloak_posts(:one)
    end

    test "visiting the index" do
      visit posts_url
      assert_selector "h1", text: "Posts"
    end

    test "creating a Post" do
      visit posts_url
      click_on "New Post"

      fill_in "Author", with: @post.author_id
      fill_in "Content", with: @post.content
      check "Featured" if @post.featured
      check "Published" if @post.published
      fill_in "Reading time", with: @post.reading_time
      fill_in "Slug", with: @post.slug
      fill_in "Summary", with: @post.summary
      fill_in "Title", with: @post.title
      fill_in "Topic", with: @post.topic
      click_on "Create Post"

      assert_text "Post was successfully created"
      click_on "Back"
    end

    test "updating a Post" do
      visit posts_url
      click_on "Edit", match: :first

      fill_in "Author", with: @post.author_id
      fill_in "Content", with: @post.content
      check "Featured" if @post.featured
      check "Published" if @post.published
      fill_in "Reading time", with: @post.reading_time
      fill_in "Slug", with: @post.slug
      fill_in "Summary", with: @post.summary
      fill_in "Title", with: @post.title
      fill_in "Topic", with: @post.topic
      click_on "Update Post"

      assert_text "Post was successfully updated"
      click_on "Back"
    end

    test "destroying a Post" do
      visit posts_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Post was successfully destroyed"
    end
  end
end
