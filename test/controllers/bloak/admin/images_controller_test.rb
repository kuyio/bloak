# frozen_string_literal: true

require "test_helper"

module Bloak
  module Admin
    class ImagesControllerTest < ActionDispatch::IntegrationTest
      include Engine.routes.url_helpers

      setup do
        @image = bloak_images(:hero)
        attach_test_image(@image, :image_file)

        bloak_images(:banner).tap { |i| attach_test_image(i, :image_file) }
      end

      # --- Auth ---

      test "index requires authentication" do
        get admin_images_url
        assert_response :unauthorized
      end

      test "index succeeds with credentials" do
        get admin_images_url, headers: { "Authorization" => admin_credentials }
        assert_response :success
      end

      # --- CRUD ---

      test "new renders form" do
        get new_admin_image_url, headers: { "Authorization" => admin_credentials }
        assert_response :success
      end

      test "create with valid params" do
        assert_difference("Image.count") do
          post admin_images_url,
            headers: { "Authorization" => admin_credentials },
            params: { image: {
              name: "new-image", alt: "New image",
              image_file: fixture_file_upload("test.png", "image/png")
            } }
        end
        assert_redirected_to admin_images_url
      end

      test "create with invalid params does not create image" do
        assert_no_difference("Image.count") do
          post admin_images_url,
            headers: { "Authorization" => admin_credentials },
            params: { image: { name: "", alt: "" } }
        end
        assert_response :unprocessable_content
      end

      test "show renders image" do
        get admin_image_url(@image), headers: { "Authorization" => admin_credentials }
        assert_response :success
      end

      test "edit renders form" do
        get edit_admin_image_url(@image), headers: { "Authorization" => admin_credentials }
        assert_response :success
      end

      test "update with valid params" do
        patch admin_image_url(@image),
          headers: { "Authorization" => admin_credentials },
          params: { image: { alt: "Updated alt" } }
        assert_redirected_to admin_images_url
        @image.reload
        assert_equal "Updated alt", @image.alt
      end

      test "update with invalid params renders edit" do
        patch admin_image_url(@image),
          headers: { "Authorization" => admin_credentials },
          params: { image: { name: "" } }
        assert_response :success
        @image.reload
        assert_not_equal "", @image.name
      end

      test "destroy removes image" do
        assert_difference("Image.count", -1) do
          delete admin_image_url(@image), headers: { "Authorization" => admin_credentials }
        end
        assert_redirected_to admin_images_url
      end

      # --- Search ---

      test "search with query returns results" do
        post admin_images_search_url,
          headers: { "Authorization" => admin_credentials },
          params: { query: "hero" }
        assert_response :success
        assert_match "hero", response.body
      end

      test "search with blank query returns all images" do
        post admin_images_search_url,
          headers: { "Authorization" => admin_credentials },
          params: { query: "" }
        assert_response :success
      end
    end
  end
end
