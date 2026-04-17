# frozen_string_literal: true

module Upcheck
  module Registry
    BUILT_IN = {}.freeze

    module_function

    def resolve(name)
      key = name.to_sym
      Upcheck.configuration.providers[key] || BUILT_IN[key] ||
        raise(UnknownProviderError, "Unknown provider: #{name.inspect}. " \
          "Register it with Upcheck.configure { |c| c.register_provider(:name, url) }.")
    end
  end
end
