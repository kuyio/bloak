# HEAD

- [BREAKING] Bloak raises a `RuntimeException` when `admin_user` or `admin_password` aren't configured
- [BREAKING] configuration options `items` was renamed to `num_items`, please update your `config/initializers/bloak.rb`
- added additional configuration options to engine: `num_featured_posts`, `max_toc_depth`
- `site_name` now defaults to parent application name if unset (the application that mounts the bloak engine)
- `copyright` now uses the `site_name` as a default
- defined `cover_image` variants in `has_one_attached` and reference variants in view templates
- preload image variants to speed up rendering time
- raise a `RecordNotFound` exception when calling the `/tag/:topic` route with an unknown topic
- raise a `RecordNotFound` exception when calling the `/author/:name` route with an unknown author name
- render a maximum of `Bloak.num_featured_posts` in featured posts
- render a maximum of `Bloak.num_items` in posts before pagination occurs
- render a table of contents depth of maximum `Bloak.max_toc_depth`
- Added `Makefile`

# 0.3.3 (2023-10-26)

- Fix issue reported by GitHub scanner

# Older

- See commit log
