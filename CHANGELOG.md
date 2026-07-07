## [Unreleased]

### Fixed

- The Heroku adapter now recognizes Heroku's maintenance status color (blue): the page status is reported as `"maintenance"` (so `Provider#maintenance?` works) and affected systems map to `"under_maintenance"` components. Previously any blue system raised a raw `KeyError`.
- The Heroku adapter raises `Upcheck::ParseError` instead of `KeyError` when Heroku reports a status color the adapter doesn't recognize, keeping the promise that every failure is an `Upcheck::Error` subclass.
- The Heroku adapter reports `"none"` instead of raising when the API returns an empty systems list.

### Added

- `Component#id` exposes the underlying provider id (e.g. the Statuspage component id), surviving display-name renames. Heroku components have no id and return `nil`.
- `Provider#component` now accepts `id:` in addition to `name:`, e.g. `provider.component(id: "k8w3r06qmzrp")`.

### Breaking changes

- `Provider#component` now takes a `name:` keyword argument instead of a positional one. Replace `provider.component("Web")` with `provider.component(name: "Web")`.

## [0.1.0] - 2026-04-16

- Initial release
