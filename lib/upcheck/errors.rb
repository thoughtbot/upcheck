# frozen_string_literal: true

module Upcheck
  class Error < StandardError; end

  class UnknownProviderError < Error; end

  class TransportError < Error; end

  class TimeoutError < TransportError; end

  class ConnectionError < TransportError; end

  class HTTPError < TransportError
    attr_reader :status

    def initialize(message, status: nil)
      super(message)
      @status = status
    end
  end

  class ParseError < Error; end
end
