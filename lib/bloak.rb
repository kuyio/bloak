require "bloak/version"
require "bloak/engine"

module Bloak
  # The name of the site, used in the Navigation Bar, and footer unless a copyright is set
  mattr_writer(:site_name)

  # The copyright notice in the footer
  mattr_writer(:copyright)

  # The username for the admin user
  mattr_writer(:admin_user)

  # The password for the admin user
  mattr_writer(:admin_password)

  # The number of blog posts to show before pagination
  mattr_writer(:num_items)

  # The number of featured posts to display
  mattr_writer(:num_featured_posts)

  # The maximum depth to render for the TOC of a post
  mattr_writer(:max_toc_depth)

  def self.configure
    yield self
  end

  def self.site_name
    @@site_name || ::Rails.application.class.module_parent
  end

  def self.admin_user
    @@admin_user || raise("You MUST configure an admin user for Bloak!")
  end

  def self.admin_password
    @@admin_password || raise("You MUST configure an admin password for Bloak!")
  end

  def self.copyright
    @@copyright || "© #{Time.now.utc.year} #{site_name} &mdash; All rights reserved.".html_safe
  end

  def self.num_items
    @@num_items || 10
  end

  def self.num_featured_posts
    @@num_featured_posts || 3
  end

  def self.max_toc_depth
    @@max_toc_depth || 3
  end
end
