require "test_helper"

module Bloak
  class ImagesControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @image = bloak_images(:one)
    end

    test "should get index" do
      get images_url
      assert_response :success
    end

    test "should get new" do
      get new_image_url
      assert_response :success
    end

    test "should create image" do
      assert_difference('Image.count') do
        post images_url, params: {image: {alt: @image.alt, name: @image.name}}
      end

      assert_redirected_to image_url(Image.last)
    end

    test "should show image" do
      get image_url(@image)
      assert_response :success
    end

    test "should get edit" do
      get edit_image_url(@image)
      assert_response :success
    end

    test "should update image" do
      patch image_url(@image), params: {image: {alt: @image.alt, name: @image.name}}
      assert_redirected_to image_url(@image)
    end

    test "should destroy image" do
      assert_difference('Image.count', -1) do
        delete image_url(@image)
      end

      assert_redirected_to images_url
    end
  end
end
