## [Unreleased]

### Fixed

- `Upcheck::HTTPClient` now wraps TLS handshake failures (`OpenSSL::SSL::SSLError`), connection resets (`Errno::ECONNRESET`), truncated responses (`EOFError`), and malformed HTTP responses (`Net::HTTPBadResponse`) in `Upcheck::ConnectionError`. Previously these raw exceptions leaked to callers, breaking the promise that every failure raises an `Upcheck::Error` subclass.

### Added

- `Component#id` exposes the underlying provider id (e.g. the Statuspage component id), surviving display-name renames. Heroku components have no id and return `nil`.
- `Provider#component` now accepts `id:` in addition to `name:`, e.g. `provider.component(id: "k8w3r06qmzrp")`.

### Breaking changes

- `Provider#component` now takes a `name:` keyword argument instead of a positional one. Replace `provider.component("Web")` with `provider.component(name: "Web")`.

## [0.1.0] - 2026-04-16

- Initial release
