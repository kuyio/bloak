# frozen_string_literal: true

require "test_helper"

class BloakConfigurationTest < ActiveSupport::TestCase
  test "has a version number" do
    assert Bloak::VERSION
  end

  test "site_name returns configured value" do
    assert_equal "Bloak Demo", Bloak.site_name
  end

  test "admin_user returns configured value" do
    assert_equal "admin", Bloak.admin_user
  end

  test "admin_password returns configured value" do
    assert_equal "password", Bloak.admin_password
  end

  test "num_items defaults to 10" do
    assert_equal 10, Bloak.num_items
  end

  test "num_featured_posts defaults to 3" do
    assert_equal 3, Bloak.num_featured_posts
  end

  test "max_toc_depth defaults to 3" do
    assert_equal 3, Bloak.max_toc_depth
  end

  test "copyright includes site name and current year" do
    copyright = Bloak.copyright
    assert_match "Bloak Demo", copyright
    assert_match Time.now.utc.year.to_s, copyright
  end

  test "engine registers default javascript" do
    assert_includes Bloak::Engine.javascripts, "bloak/application"
  end

  test "engine registers default stylesheet" do
    assert_includes Bloak::Engine.stylesheets, "bloak/application"
  end

  test "allow_erb_in_posts defaults to false" do
    assert_equal false, Bloak.allow_erb_in_posts
  end
end
