# frozen_string_literal: true

require_relative "upcheck/version"
require_relative "upcheck/errors"
require_relative "upcheck/configuration"
require_relative "upcheck/http_client"

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
  end
end
