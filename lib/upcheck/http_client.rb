# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Upcheck
  class HTTPClient
    MAX_REDIRECTS = 5
    USER_AGENT = "Upcheck/#{Upcheck::VERSION} (+https://github.com/MatheusRich/upcheck)"

    def initialize(timeout: Upcheck.configuration.http_timeout)
      @timeout = timeout
    end

    def get_json(url)
      JSON.parse(get(url))
    rescue JSON::ParserError => e
      raise ParseError, "Unable to parse JSON response: #{e.message}"
    end

    private

    attr_reader :timeout

    def get(url, redirects_left: MAX_REDIRECTS)
      uri = URI.parse(url)
      response = perform_request(uri)

      case response
      when Net::HTTPSuccess
        response.body.to_s
      when Net::HTTPRedirection
        follow_redirect(response, uri, redirects_left)
      else
        raise HTTPError.new(
          "Unexpected HTTP response: #{response.code} #{response.message}",
          status: response.code.to_i
        )
      end
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      raise TimeoutError, "Request to #{url} timed out: #{e.message}"
    rescue SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ENETUNREACH => e
      raise ConnectionError, "Unable to connect to #{url}: #{e.message}"
    end

    def perform_request(uri)
      Net::HTTP.start(
        uri.host,
        uri.port,
        use_ssl: uri.scheme == "https",
        open_timeout: timeout,
        read_timeout: timeout
      ) do |http|
        request = Net::HTTP::Get.new(uri.request_uri)
        request["User-Agent"] = USER_AGENT
        request["Accept"] = "application/json"
        http.request(request)
      end
    end

    def follow_redirect(response, original_uri, redirects_left)
      if redirects_left <= 0
        raise HTTPError.new("Too many redirects starting at #{original_uri}", status: response.code.to_i)
      end

      location = response["location"]
      if location.nil? || location.empty?
        raise HTTPError.new("Redirect response missing Location header", status: response.code.to_i)
      end

      next_url = URI.join(original_uri.to_s, location).to_s
      get(next_url, redirects_left: redirects_left - 1)
    end
  end
end
