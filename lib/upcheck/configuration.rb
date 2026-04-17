# frozen_string_literal: true

module Upcheck
  class Configuration
    DEFAULT_HTTP_TIMEOUT = 5

    attr_accessor :http_timeout
    attr_reader :providers

    def initialize
      @http_timeout = DEFAULT_HTTP_TIMEOUT
      @providers = {}
      Registry.register_defaults(self)
    end

    def register_provider(name, &block)
      raise ArgumentError, "register_provider requires a block returning an adapter" unless block

      @providers[name.to_sym] = block
    end
  end
end
