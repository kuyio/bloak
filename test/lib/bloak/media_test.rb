# frozen_string_literal: true

require "test_helper"

module Bloak
  class MediaTest < ActiveSupport::TestCase
    setup do
      @image = bloak_images(:hero)
      attach_test_image(@image, :image_file)
    end

    test "image finds by name" do
      assert_equal @image, Media.image("hero-image")
    end

    test "image returns nil for unknown name" do
      assert_nil Media.image("nonexistent")
    end

    test "image_alt returns alt text" do
      assert_equal "A hero image", Media.image_alt("hero-image")
    end

    test "image_alt returns nil for unknown name" do
      assert_nil Media.image_alt("nonexistent")
    end

    test "image_file returns attachment" do
      result = Media.image_file("hero-image")
      assert result.attached?
    end

    test "image_file returns nil for unknown name" do
      assert_nil Media.image_file("nonexistent")
    end

    test "image_url returns url for attached image" do
      url = Media.image_url("hero-image")
      assert url.present?
    end
  end
end
