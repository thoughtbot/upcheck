# frozen_string_literal: true

module Upcheck
  module Registry
    BUILT_IN = {
      anthropic: -> { Adapters::Statuspage.new("https://status.claude.com") },
      openai: -> { Adapters::Statuspage.new("https://status.openai.com") },
      github: -> { Adapters::Statuspage.new("https://www.githubstatus.com") },
      twilio: -> { Adapters::Statuspage.new("https://status.twilio.com") },
      datadog: -> { Adapters::Statuspage.new("https://status.datadoghq.com") },
      rubygems: -> { Adapters::Statuspage.new("https://status.rubygems.org") },
      cloudflare: -> { Adapters::Statuspage.new("https://www.cloudflarestatus.com") },
      discord: -> { Adapters::Statuspage.new("https://discordstatus.com") },
      digitalocean: -> { Adapters::Statuspage.new("https://status.digitalocean.com") },
      vercel: -> { Adapters::Statuspage.new("https://www.vercel-status.com") },
      stripe: -> { Adapters::Statuspage.new("https://www.stripestatus.com") },
      shopify: -> { Adapters::Statuspage.new("https://www.shopifystatus.com") },
      sentry: -> { Adapters::Statuspage.new("https://status.sentry.io") }
    }.freeze

    extend self

    def register_defaults(config)
      BUILT_IN.each do |name, factory|
        config.register_provider(name, &factory)
      end
    end

    def resolve(name)
      factory = Upcheck.configuration.providers[name.to_sym]
      unless factory
        raise UnknownProviderError, "Unknown provider: #{name.inspect}. " \
          "Register it with Upcheck.configure { |c| c.register_provider(:name) { adapter } }."
      end

      factory.call
    end
  end
end
