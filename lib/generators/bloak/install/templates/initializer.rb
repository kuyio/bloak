# frozen_string_literal: true

Bloak.configure do |config|
  # The name displayed in the navigation bar and footer
  config.site_name = "My Blog"

  # Admin credentials for the /blog/admin panel
  config.admin_user = ENV.fetch("BLOAK_ADMIN_USER", "admin")
  config.admin_password = ENV.fetch("BLOAK_ADMIN_PASSWORD", "changeme")

  # Number of posts per page
  # config.num_items = 10

  # Number of featured posts on the index page
  # config.num_featured_posts = 3

  # Maximum heading depth for the table of contents
  # config.max_toc_depth = 3

  # Use your app's own layout instead of the built-in one
  # config.layout = "application"

  # Custom copyright notice (supports HTML)
  # config.copyright = "&copy; #{Time.now.utc.year} My Company"

  # Allow ERB in post content (DANGEROUS: enables arbitrary code execution)
  # Only enable if you trust all admin users with full server access.
  # Default is false - uses sandboxed Liquid templates instead.
  # config.allow_erb_in_posts = false
end
