# Bloak Dummy App

This is a minimal Rails 8.1 application used to develop and test the Bloak engine. It mounts the engine at `/blog` and provides seed data with sample posts and images.

## Setup

From the engine root:

```sh
bundle install
rails db:create db:migrate
rails db:seed
```

## Running

```sh
cd test/dummy
bin/rails server
```

- Blog: http://localhost:3000/blog
- Admin: http://localhost:3000/blog/admin (user: `admin`, password: `password`)

## Testing

From the engine root:

```sh
make test    # lint + vulnerability scan
rake test    # full test suite
```
