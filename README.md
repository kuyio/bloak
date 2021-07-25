# Bloak

Bloak is a Ruby on Rails engine to provide the functionality of a micro-blog based on rendering articles written in Markdown.

## Usage

Usually, specifying the engine inside your application's `Gemfile` would be done by adding it as a normal, everyday gem.

```ruby
gem 'bloak'
```

However, because we have not released the `Bloak` engine on the official rubygems.org repository, we will need to specify the `git` option:

```ruby
# Blog
gem 'bloak', git: "ssh://git@git.kuy.io:7999/www/bloak.git"
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

To run these migrations within the context of the application, simply run `bin/rails db:migrate`.

## Configuration

You can configure the Bloak engine through an initializer file at `main_app/config/initializers/bloak.rb`

```ruby
Bloak.configure do |c|
  c.site_name = "My Awesome Blog"
  c.admin_user = "admin"
  c.admin_password = "admin"
end
```

Also make sure to set your "default_host", so absolute URLs to your assets can be correctly generated, for example in `config/application.rb`:

```ruby
# Default Host for URL Helpers
routes.default_url_options[:host] = 'my-blog.com'
```

**Note:** Assinging a `nil` or empty value to `admin_user` or `admin_password` will disable authentication for the admin routes of the engine.

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

The custom Markdown engine also supports `ERB` tags in the Markdown content. You can pass local variables (`assigns`) into the ERB template engine by passing a Hash to the `Bloak::Post.render()` method.

## Contributing

Contribution directions go here.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
