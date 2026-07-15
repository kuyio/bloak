# Security

Bloak is designed to be a safe default for adding a blog to your Rails application. This document describes the security model, what protections are in place, and what you need to get right in your deployment.

## Rendering Pipeline

Post content passes through a four-stage pipeline before reaching the browser:

1. **Liquid** — Template tags are processed in a sandboxed environment. Liquid cannot access Ruby methods, the filesystem, or system calls. Code fences are protected from Liquid processing.
2. **CommonMarker** — Markdown is rendered to HTML using a CommonMark-compliant parser.
3. **Nokogiri post-processing** — Heading classes, link attributes, and syntax highlighting are applied.
4. **Dandruff** — All HTML output is sanitized through an allowlist before being served. Only tags and attributes that the rendering pipeline legitimately produces are permitted. Scripts, iframes, event handlers, and `data:` URIs are stripped.

This means that even if an admin writes `<script>alert(1)</script>` in a post, the script tag is removed before it reaches any visitor.

### ERB Legacy Mode

Bloak includes an opt-in `config.allow_erb_in_posts = true` setting that replaces Liquid with ERB for template processing. **ERB executes arbitrary Ruby code.** Enabling this grants every admin user the ability to run code on your server. Only enable it if you fully trust all admin users with production server access and understand that any compromise of admin credentials becomes a remote code execution vulnerability.

ERB mode is disabled by default and must be explicitly opted into.

## Cross-Site Scripting (XSS)

Bloak defends against XSS at multiple layers:

- **HTML sanitization** — Dandruff strips all tags and attributes not on the allowlist. This covers stored XSS from post content, image alt text, and custom Liquid tag output.
- **Heading anchors** — CommonMarker generates anchor links inside headings. These use `#`-prefixed hrefs and are excluded from the `target="_blank"` post-processing to avoid unintended navigation.
- **Page titles** — Post titles rendered in `<title>` tags are auto-escaped by Rails. No `html_safe` is used.
- **Copyright footer** — The default copyright string uses plain UTF-8 characters, not HTML entities, and is not marked `html_safe`.
- **Media tags** — Image names and alt text are HTML-escaped via `ERB::Util.html_escape` before interpolation into media tag output.
- **Code blocks** — Content inside `<pre>` blocks is excluded from Dandruff sanitization to preserve code samples that contain angle brackets (e.g. Ruby inspect output like `#<User id: 1>`).

## Content Security Policy

Bloak sets a per-controller Content Security Policy on all engine routes:

- `script-src 'self'` — No inline scripts, no external script sources.
- `style-src 'self' 'unsafe-inline'` — Stylesheets from the app only. `unsafe-inline` is required by Bootstrap.
- `img-src 'self' data: https://gravatar.com` — Images from the app, data URIs for inline assets, and Gravatar for author avatars.
- `frame-src 'none'` / `object-src 'none'` — No embedded frames or plugins.

This policy applies only to Bloak routes. If you use your own layout (`config.layout = "application"`), your host app's CSP applies instead.

## Cross-Site Request Forgery (CSRF)

All state-changing admin actions (create, update, delete, toggle published/featured) use `POST`, `PATCH`, or `DELETE` methods and are protected by Rails CSRF tokens. No state changes happen via GET requests.

The public-facing blog uses only GET requests for reading content and POST for search.

## Authentication

The admin panel uses HTTP Basic Auth. This is simple and stateless but has inherent limitations:

- **No brute-force protection.** Bloak does not throttle failed login attempts. Use [Rack::Attack](https://github.com/rack/rack-attack) or your reverse proxy (nginx, Cloudflare, etc.) to rate-limit requests to `/blog/admin`.
- **No session timeout.** Basic Auth credentials are sent on every request; there is no session to expire.
- **Credentials in transit.** Basic Auth transmits credentials Base64-encoded (not encrypted). **HTTPS is required for production.** Without TLS, credentials can be intercepted.
- **No multi-factor authentication.** Consider placing the admin panel behind a VPN or IP allowlist for additional protection.

### Credential Configuration

The install generator requires `BLOAK_ADMIN_USER` and `BLOAK_ADMIN_PASSWORD` environment variables with no fallback defaults. If either is missing, the application raises an error at boot time. The engine itself raises a `RuntimeError` if `admin_user` or `admin_password` are not configured.

## File Uploads

Bloak accepts image uploads for post cover images and the image library. Uploads are validated at two levels:

- **Content type** — Only `image/jpeg` and `image/png` MIME types are accepted.
- **File extension** — The filename must end in `.jpg`, `.jpeg`, or `.png`. This prevents extension-spoofing attacks where a malicious file (e.g. an SVG with embedded JavaScript) is uploaded with a forged `Content-Type` header.
- **File size** — Uploads are limited to 10 MB.

Uploaded images are stored via Active Storage. Configure your Active Storage service appropriately for production (e.g. S3 with private access, signed URLs).

## SQL Injection

All database queries use ActiveRecord's parameterized query methods. Full-text search uses `pg_search` which generates parameterized queries internally. No raw SQL interpolation exists in the codebase.

## Namespace Isolation

Bloak uses `isolate_namespace Bloak` in its engine definition. This means:

- All models, controllers, and routes are namespaced under `Bloak::`.
- The engine's database tables are prefixed with `bloak_`.
- The engine's routes do not conflict with host app routes.
- The engine does not pollute the host app's autoload paths.

## Common Misconfiguration Pitfalls

### Enabling ERB mode

Setting `config.allow_erb_in_posts = true` removes the Liquid sandbox and grants full Ruby execution to anyone who can create or edit posts. This is the single most dangerous configuration option. Leave it disabled unless you have a specific need and fully understand the implications.

### Missing HTTPS

Running the admin panel over plain HTTP exposes credentials to network-level attackers. Always terminate TLS before your Rails application in production.

### Weak or shared admin credentials

Bloak uses a single shared admin credential. If multiple people need admin access, they all share the same username and password. Consider placing the admin behind an authentication proxy for audit logging and individual accountability.

### Forgetting rate limiting

Without Rack::Attack or equivalent, an attacker can brute-force the admin password at network speed. This is especially dangerous with weak passwords.

### Active Storage misconfiguration

If Active Storage serves blobs publicly without signed URLs, uploaded images (including any that bypass validation) are accessible to anyone with the URL. Configure your storage service with appropriate access controls.

## Reporting Vulnerabilities

If you discover a security vulnerability in Bloak, please report it privately by emailing [info@kuy.io](mailto:info@kuy.io). Do not open a public GitHub issue for security vulnerabilities.
