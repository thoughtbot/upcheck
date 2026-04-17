# frozen_string_literal: true

require_relative "upcheck/version"
require_relative "upcheck/errors"
require_relative "upcheck/configuration"
require_relative "upcheck/http_client"
require_relative "upcheck/resource"
require_relative "upcheck/component"
require_relative "upcheck/incident"
require_relative "upcheck/registry"
require_relative "upcheck/adapters/statuspage"
require_relative "upcheck/provider"

module Upcheck
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end

    def reset!
      @configuration = Configuration.new
    end

    def for(name)
      Provider.new(Adapters::Statuspage.new(Registry.resolve(name)))
    end
  end
end
