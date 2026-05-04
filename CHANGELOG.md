## [Unreleased]

### Added

- `Component#id` exposes the underlying provider id (e.g. the Statuspage component id), surviving display-name renames. Heroku components have no id and return `nil`.
- `Provider#component` now accepts `id:` in addition to `name:`, e.g. `provider.component(id: "k8w3r06qmzrp")`.

### Breaking changes

- `Provider#component` now takes a `name:` keyword argument instead of a positional one. Replace `provider.component("Web")` with `provider.component(name: "Web")`.

## [0.1.0] - 2026-04-16

- Initial release
