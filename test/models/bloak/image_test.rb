# frozen_string_literal: true

require "test_helper"

module Bloak
  class ImageTest < ActiveSupport::TestCase
    setup do
      @image = bloak_images(:hero)
      attach_test_image(@image, :image_file)
    end

    test "valid image with all attributes and file" do
      assert @image.valid?
    end

    test "invalid without name" do
      @image.name = nil
      assert_not @image.valid?
      assert_includes @image.errors[:name], "can't be blank"
    end

    test "invalid without alt" do
      @image.alt = nil
      assert_not @image.valid?
      assert_includes @image.errors[:alt], "can't be blank"
    end

    test "invalid with duplicate name" do
      dupe = Image.new(name: @image.name, alt: "duplicate")
      attach_test_image(dupe, :image_file)
      assert_not dupe.valid?
      assert_includes dupe.errors[:name], "has already been taken"
    end

    test "invalid without image_file" do
      @image.image_file.purge
      assert_not @image.valid?
      assert_includes @image.errors[:image], "is required"
    end

    test "invalid with non-image mime type" do
      @image.image_file.attach(
        io: File.open(file_fixture("test.gif")),
        filename: "test.gif",
        content_type: "image/gif"
      )
      assert_not @image.valid?
      assert @image.errors[:image].any? { |e| e.include?("JPEG or PNG") }
    end

    test "rejects file with valid content type but wrong extension" do
      @image.image_file.attach(
        io: File.open(file_fixture("test.png")),
        filename: "image.svg",
        content_type: "image/png"
      )
      assert_not @image.valid?
      assert @image.errors[:image].any? { |e| e.include?("JPEG or PNG") }
    end

    test "image_url returns path when attached" do
      assert_not_equal "#", @image.image_url
    end

    test "image_url returns # when not attached" do
      @image.image_file.purge
      assert_equal "#", @image.image_url
    end

    test "image_variant_url returns # when not attached" do
      @image.image_file.purge
      assert_equal "#", @image.image_variant_url(resize_to_limit: [100, 100])
    end

    test "search_by_name finds matching images" do
      results = Image.search_by_name("hero")
      assert_includes results, @image
    end

    test "search_by_name returns empty for no match" do
      results = Image.search_by_name("nonexistent")
      assert_empty results
    end
  end
end
