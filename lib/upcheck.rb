# frozen_string_literal: true

require_relative "upcheck/version"
require_relative "upcheck/configuration"

module Upcheck
  class Error < StandardError; end

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
