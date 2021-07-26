# Bloak

Bloak is a Ruby on Rails engine to provide the functionality of a micro-blog with articles written in Markdown.

## Features

- [x] Responsive and mobile friendly
- [x] Google Lighthouse score of 90+ on all categories
- [x] Write Blog posts in Markdown format (extended Github-flavoured markdown)
- [x] SimpleDME markdown editor integration
- [x] Custom Markdown tags for info, warning, quote boxes, table-of-contents and more
- [x] Syntax highlighting for fenced code blocks provided by Rouge
- [x] Custom Markdown renderer supports ERB and HTML tags in Markdown
- [x] Cover images for posts with automatic resizing of preview images
- [x] Post categories
- [x] Filtering for categories
- [x] Full-text search for posts
- [x] Open-Graph meta tags for sharing posts with Twitter, Facebook, Linked-In
- [x] SEO meta tags for blog posts
- [x] Author gravatar images
- [x] Image uploads
- [x] Reading time estimation for articles
- [x] (Optionally) Featured articles that are always displayed on top
- [x] Extensible and customizable view templates and styles
- [x] Admin Interface with authentication
- [x] Uses Bootstrap 5 front-end framework
- [x] Uses Fontawesome 5 icons

## Installation

Usually, specifying the engine inside your application's `Gemfile` would be done by adding it as a normal, everyday gem. However, because we have not released the `Bloak` engine on the official rubygems.org repository, we will need to specify the `git` option:

```ruby
# Blog
gem 'bloak', git: "https://github.com/kuyio/bloak.git"
```

Then run `bundle` to install the gem.

As described earlier, by placing the gem in the `Gemfile` it will be loaded when Rails is loaded. It will first require `lib/bloak.rb` from the engine, then `lib/bloak/engine.rb`, which is the file that defines the major pieces of functionality for the engine.

To make the engine's functionality accessible from within an application, it needs to be mounted in that application's `config/routes.rb` file:

```ruby
mount Bloak::Engine, at: "/blog"
```

The engine contains migrations for the `bloak_articles` and `bloak_images` tables which need to be created in the application's database so that the engine's models can query them correctly. To copy these migrations into the application run the following command from the application's root:

```sh
$ bin/rails bloak:install:migrations
```

Additionally, we require `ActiveStorage` to be installed in your Rails application. If you haven't done so yet, now is a good time to run `bin/rails active_storage:install`. Please note, that we are using the `image_processing` gem to create preview images and image variants, which in turn requires `imagemagick` to be installed on your system.

Then, run all migrations within the context of the application with `bin/rails db:migrate`.

## Configuration

You can configure the Bloak engine through an initializer file at `main_app/config/initializers/bloak.rb`

```ruby
Bloak.configure do |c|
  c.site_name = "My Awesome Blog"
  c.admin_user = "admin"
  c.admin_password = "admin"
end
```

**Note:** Assinging a `nil` or empty value to `admin_user` or `admin_password` will disable authentication for the admin routes of the engine.

Also make sure to set your `default_url_options`, so absolute URLs to your assets can be correctly generated, for example in `config/application.rb`:

```ruby
# Default Host for URL Helpers
routes.default_url_options[:host] = 'my-blog.com'
routes.default_url_options[:protocol] = 'https'
```

## The Admin Interface

You can access the admin interface under the `/admin` sub-path of your engine mount, for example, if you mounted the engine at `/blog` the admin UI is available at `/blog/admin`. The Admin UI is secured by HTTP Basic Auth if both `admin_user` and `admin_password` are set in the `Bloak` configuration (see above).

Within the admin UI, you can upload images for embedding within Blog posts, as well as write and manage Blog posts.

## Writing Posts

Post content can be written in GitHub-flavoured markdown syntax with a few custom Markdown tag extensions. Additionally we support `HTML` tags and `ERB` tags (see below).

### Custom Markdown Tags

The `Bloak` Engine includes a custom Markdown render, that introduces a number of additional tags beyond GitHub-flavoured Markdown.

- `!! text` renders a danger alert box with icon and the text given in the paragraph
- `!w text` renders a warning alert box with icon and the text given in the paragraph
- `!i text` renders an info box with icon and the text given in the paragraph
- `!q text` renders a quote box with icon and the text given in the paragraph
- `!media[name]` inserts an Image (make sure to upload and name it) identified by its unique name
- `!toc` or `!toc[label]` inserts a level-1 table of contents at this position, with an optional `label`

### ERB Content

The custom Markdown engine also supports `ERB` tags outside of fenced code blocks, in the Markdown content of your article.
You can pass local variables (`assigns`) into the ERB template engine by passing a Hash to the `Bloak::Post.render()` method.

## Customizations and Styles

You can create or copy the following files from the Bloak engine to customize the rendering of Header, and Footer, as well as to include custom styles and JavaScripts:

```
views/
  bloak/
    application/
      _stylesheet.html.erb
      _javascript.html.erb
      _meta_tags.html.erb
      _header.html.erb
      _footer.html.erb
```

You can create or copy the following files from the Bloak engine inside the host application to customize the rendering of Post index, Post display and display of search results:

```
views/
  bloak/
    posts/
      index.html.erb
      show.html.erb
      search.html.erb
      _topics.html.erb
      _post_list.html.erb
```

You can customize the brand logo rendered in the navbar by adding your own file to `app/assets/images/logo.png`.

You can customize the favicon rendered in the browser tab by adding your own file to `app/assets/images/favicon.png`.

## Roadmap

- [ ] Support for article keyword lists
- [ ] Full authentication system beyond basic auth
- [ ] Commenting system
- [ ] Update UI to Hotwire
- [ ] Rake tasks to copy views from engine
- [ ] Improved customization options and splitting into additional partials
- [ ] Rework CSS classes to allow using frameworks other than Bootstrap

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
