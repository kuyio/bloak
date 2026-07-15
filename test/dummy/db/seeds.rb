# frozen_string_literal: true

seed_dir = Rails.root.join("db/seeds")

posts = [
  {
    cover: "cover-1.jpg",
    title: "Getting Started with Bloak",
    topic: "tutorials",
    summary: "Learn how to set up Bloak as your Rails blog engine in just a few minutes.",
    content: <<~MD,
      ## Welcome to Bloak

      Bloak is a **markdown blog engine** for Ruby on Rails. It ships as a mountable engine
      that you can drop into any Rails application.

      ### Installation

      Add the gem to your `Gemfile`:

      ```ruby
      gem "bloak"
      ```

      Then run the install generator:

      ```sh
      rails generate bloak:install
      ```

      This mounts the engine, creates the initializer, and runs migrations.

      ### Configuration

      Edit the initializer at `config/initializers/bloak.rb`:

      ```ruby
      Bloak.configure do |config|
        config.site_name = "My Blog"
        config.admin_user = ENV["BLOG_ADMIN_USER"]
        config.admin_password = ENV["BLOG_ADMIN_PASSWORD"]
      end
      ```

      That's it — you're ready to start writing posts!
    MD
    author_name: "Demo Author",
    author_email: "demo@example.com",
    published: true,
    featured: true,
    published_at: 3.days.ago
  },
  {
    cover: "cover-2.jpg",
    title: "All Bloak Features in One Post",
    topic: "tutorials",
    summary: "A comprehensive demo of every Bloak markdown feature: code, tables, custom tags, and more.",
    content: <<~MARKDOWN,
      {% toc "What's In This Post" %}

      ## Text Formatting

      Regular paragraphs with **bold**, *italic*, ~~strikethrough~~, and `inline code`.
      You can also write [links](https://example.com) and reference images.

      ## Code Blocks

      Fenced code blocks with syntax highlighting:

      ```ruby
      class Post < ApplicationRecord
        # Inspect output: #<Post id: 1, title: "Hello">
        def greet(name)
          puts "Hello, \#{name}!"
        end
      end
      ```

      JavaScript works too:

      ```javascript
      const greet = (name) => {
        console.log(`Hello, ${name}!`);
      };
      ```

      And plain text blocks:

      ```
      No syntax highlighting here.
      Just plain text in a code fence.
      ```

      ## Lists

      Unordered lists:

      - Item one
      - Item two
        - Nested item A
        - Nested item B
      - Item three

      Ordered lists:

      1. First step
      2. Second step
      3. Third step

      ## Blockquotes

      > Markdown is intended to be as easy-to-read and easy-to-write
      > as is feasible. — John Gruber

      ## Tables

      | Feature | Status | Notes |
      |---------|--------|-------|
      | Markdown | Supported | CommonMarker |
      | Code highlighting | Supported | Rouge |
      | Tables | Supported | GFM |
      | Custom tags | Supported | Liquid |

      ## Headings at Every Level

      ### Level 3 Heading

      Content under a level 3 heading.

      #### Level 4 Heading

      Content under a level 4 heading.

      ##### Level 5 Heading

      Content under a level 5 heading.

      ## Custom Tags

      ### Danger Box

      {% danger %}Backup your database before running migrations in production.{% enddanger %}

      ### Warning Box

      {% warning %}This feature is experimental and may change in future releases.{% endwarning %}

      ### Info Box

      {% info %}Bloak uses Liquid templates for safe, sandboxed content rendering.{% endinfo %}

      ### Quote Box

      {% quote %}The best way to predict the future is to invent it. — Alan Kay{% endquote %}

      ## Media Embeds

      You can embed uploaded images with the media tag:

      {% media "sample-hero" %}

      If an image doesn't exist, you get a clear error:

      {% media "nonexistent-image" %}

      ## Liquid Variables

      Liquid templates support variable interpolation. When rendering with assigns,
      variables like `{%raw%}{{ post.title }}{%endraw%}` are replaced with their values.

      ## Links and Autolinks

      Regular links: [Visit Example](https://example.com)

      Autolinked URLs: https://github.com/kuyio/bloak

      ## Horizontal Rules

      Content above the rule.

      ---

      Content below the rule.
    MARKDOWN
    author_name: "Demo Author",
    author_email: "demo@example.com",
    published: true,
    featured: true,
    published_at: 2.days.ago
  },
  {
    cover: "cover-3.jpg",
    title: "Managing Images",
    topic: "tutorials",
    summary: "How to upload and use images in your Bloak posts.",
    content: <<~MD,
      ## Image Management

      Bloak includes a built-in image library backed by Active Storage.
      Upload images through the admin panel and reference them in your posts.

      ### Uploading

      Navigate to the admin panel and click **Images** to manage your library.
      Supported formats are JPEG and PNG.

      ### Using Images in Posts

      Reference uploaded images by name using the media tag:

      ```
      {%raw%}{% media "my-image" %}{%endraw%}
      ```

      ### Cover Images

      Every post requires a cover image. This is displayed on the index page
      and at the top of the post detail view.
    MD
    author_name: "Demo Author",
    author_email: "demo@example.com",
    published: true,
    featured: false,
    published_at: 1.day.ago
  },
  {
    cover: "cover-4.jpg",
    title: "Customizing Your Blog",
    topic: "guides",
    summary: "Explore the configuration options available in Bloak.",
    content: <<~MD,
      ## Configuration Options

      Bloak provides several configuration options through its initializer:

      | Option | Default | Description |
      |--------|---------|-------------|
      | `site_name` | App name | Displayed in the header |
      | `num_items` | 10 | Posts per page |
      | `num_featured_posts` | 3 | Featured posts on index |
      | `max_toc_depth` | 3 | Table of contents depth |

      ### Overriding Views

      Copy engine views to your app for full control:

      ```sh
      rails generate bloak:views
      rails generate bloak:views --scope=posts
      ```

      ### CSS Theming

      Override CSS custom properties to match your brand:

      ```css
      :root {
        --bloak-link: #e63946;
        --bloak-heading: #1d3557;
        --bloak-bg: #ffffff;
      }
      ```

      ### Custom Stylesheets

      Add your own stylesheets to customize the look and feel:

      ```ruby
      Bloak::Engine.add_stylesheet("my_custom_blog_styles")
      ```
    MD
    author_name: "Demo Author",
    author_email: "demo@example.com",
    published: true,
    featured: false,
    published_at: 6.hours.ago
  },
  {
    cover: "cover-5.jpg",
    title: "Draft Post — Work in Progress",
    topic: "general",
    summary: "This is an unpublished draft post for testing the admin workflow.",
    content: <<~MD,
      ## Coming Soon

      This post is still a draft. It will only be visible in the admin panel,
      not on the public-facing blog.

      TODO:
      - [ ] Finish writing content
      - [ ] Add cover image
      - [ ] Review and publish
    MD
    author_name: "Demo Author",
    author_email: "demo@example.com",
    published: false,
    featured: false,
    published_at: nil
  }
]

posts.each do |attrs|
  cover = attrs.delete(:cover)
  post = Bloak::Post.find_or_initialize_by(title: attrs[:title])
  post.assign_attributes(attrs)
  post.cover_image.attach(
    io: File.open(seed_dir.join(cover)),
    filename: cover,
    content_type: "image/jpeg"
  )
  post.save!
  status = post.published? ? "published" : "draft"
  puts "  Post: #{post.title} (#{status})"
end

images = [
  { name: "sample-hero", alt: "A sample hero image", file: "image-1.jpg" },
  { name: "sample-thumbnail", alt: "A sample thumbnail image", file: "image-2.jpg" },
  { name: "sample-banner", alt: "A sample banner image", file: "image-3.jpg" }
]

images.each do |attrs|
  image = Bloak::Image.find_or_initialize_by(name: attrs[:name])
  image.alt = attrs[:alt]
  image.image_file.attach(
    io: File.open(seed_dir.join(attrs[:file])),
    filename: attrs[:file],
    content_type: "image/jpeg"
  )
  image.save!
  puts "  Image: #{image.name}"
end

puts "Seeded #{Bloak::Post.count} posts and #{Bloak::Image.count} images."
