# Upcheck

Upcheck is a zero-dependency Ruby gem for reading the public status of
third-party services. Use it to show degradation banners, fail fast in
background jobs, or fall back to another provider when a dependency is down.

The entry point is `Upcheck.for(:provider)`, which reads like a sentence:

```ruby
Upcheck.for(:anthropic).operational?                       # => true
Upcheck.for(:openai).incidents                             # => [#<Upcheck::Incident ...>]
Upcheck.for(:github).component("Git Operations").operational?
```

> [!NOTE]
> Upcheck currently reads from services that publish a public
> [Atlassian Statuspage](https://www.atlassian.com/software/statuspage) v2 API
> (the majority of SaaS status pages). Support for other providers can be added
> later without changing this public interface.

## Installation

Add to your Gemfile:

```bash
bundle add upcheck
```

Or install it manually:

```bash
gem install upcheck
```

Upcheck requires Ruby 3.0+ and has no runtime dependencies beyond the standard library.

## Quick start

```ruby
require "upcheck"

provider = Upcheck.for(:anthropic)

# Boolean query methods (primary interface)
provider.operational?     # => true when the provider reports no incidents
provider.degraded?        # => true for minor degradation
provider.major_outage?    # => true for major or critical outages
provider.maintenance?     # => true when the page is in a planned maintenance window

# Raw indicator string, useful for logging or serialization
provider.status           # => "none" | "minor" | "major" | "critical" | "maintenance"
provider.description      # => "All Systems Operational"

# Components
provider.components       # => [#<Upcheck::Component name="Claude API", ...>, ...]
api = provider.component("Claude API")  # returns nil if no component by that name
api.operational?         # => false
api.status               # => "degraded_performance"

# Active incidents
incident = provider.incidents.first
incident.name             # => "Elevated error rates on ..."
incident.impact           # => "minor"
incident.updates.last.body

# Active scheduled maintenances (same shape as incidents)
provider.scheduled_maintenances
```

Each provider object caches the JSON it fetches, so repeat calls to `operational?`, `components`, etc. on the same provider don't re-hit the network. Build a new provider with `Upcheck.for(...)` when you want fresh data.

## Configuration

```ruby
Upcheck.configure do |config|
  config.http_timeout = 3
  config.register_provider(:my_saas, "https://status.my-saas.example.com")
end
```

| Option | Default | Description |
|---|---|---|
| `http_timeout` | `5` | Seconds to wait for both open and read on each HTTP request. |
| `register_provider(name, url)` | (none) | Registers a custom provider by symbol name and base URL. The URL must be the root of a service that exposes the Atlassian Statuspage v2 API (i.e., `<url>/api/v2/status.json` returns the expected JSON). Overrides built-ins when the name matches. |

## Built-in providers

Upcheck ships with a registry of well-known providers so you can reference them by symbol:

| Symbol | URL |
|---|---|
| `:anthropic` | https://status.claude.com |
| `:openai` | https://status.openai.com |
| `:github` | https://www.githubstatus.com |
| `:twilio` | https://status.twilio.com |
| `:datadog` | https://status.datadoghq.com |
| `:rubygems` | https://status.rubygems.org |
| `:cloudflare` | https://www.cloudflarestatus.com |
| `:discord` | https://discordstatus.com |
| `:digitalocean` | https://status.digitalocean.com |
| `:vercel` | https://www.vercel-status.com |
| `:stripe` | https://www.stripestatus.com |
| `:shopify` | https://www.shopifystatus.com |
| `:sentry` | https://status.sentry.io |

Missing one? Register it at runtime. Any service hosted on Atlassian Statuspage
will work.

```ruby
Upcheck.configure do |config|
  config.register_provider(:shopify, "https://www.shopifystatus.com")
end

Upcheck.for(:shopify).operational?
```

## Errors

Every failure raises a specific subclass of `Upcheck::Error`:

| Exception | When it's raised |
|---|---|
| `Upcheck::UnknownProviderError` | `Upcheck.for(:name)` was called with a provider that isn't registered. |
| `Upcheck::TimeoutError` | The HTTP request exceeded `http_timeout`. |
| `Upcheck::ConnectionError` | DNS failure, refused connection, unreachable host. |
| `Upcheck::HTTPError` | The server returned a non-success response (4xx, 5xx, or too many redirects). `#status` holds the HTTP code. |
| `Upcheck::ParseError` | The body wasn't valid JSON. |
| `Upcheck::TransportError` | Parent of `TimeoutError`, `ConnectionError`, and `HTTPError`. Rescue this to catch any transport failure. |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/MatheusRich/upcheck.

1. Fork the repository.
2. Create a topic branch (`git checkout -b my-new-feature`).
3. Add tests for your change and make them pass (`bundle exec rspec`).
4. Commit (`git commit -am "Add my new feature"`).
5. Push (`git push origin my-new-feature`).
6. Open a pull request.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
