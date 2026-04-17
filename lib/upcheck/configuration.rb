# frozen_string_literal: true

module Upcheck
  class Configuration
    DEFAULT_HTTP_TIMEOUT = 5

    attr_accessor :http_timeout
    attr_reader :providers

    def initialize
      @http_timeout = DEFAULT_HTTP_TIMEOUT
      @providers = {}
    end

    def register_provider(name, base_url)
      @providers[name.to_sym] = base_url.to_s
    end
  end
end
