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

**Note:** Assinging a `nil` or empty value to `admin_user` or `admin_password` will disable authentication for the admin routes of the engine.

## Contributing

Contribution directions go here.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
