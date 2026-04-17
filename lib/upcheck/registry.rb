# frozen_string_literal: true

module Upcheck
  module Registry
    BUILT_IN = {
      anthropic: "https://status.claude.com",
      openai: "https://status.openai.com",
      github: "https://www.githubstatus.com",
      twilio: "https://status.twilio.com",
      datadog: "https://status.datadoghq.com",
      rubygems: "https://status.rubygems.org",
      cloudflare: "https://www.cloudflarestatus.com",
      discord: "https://discordstatus.com",
      digitalocean: "https://status.digitalocean.com",
      vercel: "https://www.vercel-status.com"
    }.freeze

    extend self

    def resolve(name)
      key = name.to_sym
      Upcheck.configuration.providers[key] || BUILT_IN[key] ||
        raise(UnknownProviderError, "Unknown provider: #{name.inspect}. " \
          "Register it with Upcheck.configure { |c| c.register_provider(:name, url) }.")
    end
  end
end
