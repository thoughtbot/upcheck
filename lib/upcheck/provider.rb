# frozen_string_literal: true

module Upcheck
  class Provider
    INDICATOR_NONE = "none"
    INDICATOR_MINOR = "minor"
    INDICATOR_MAJOR = "major"
    INDICATOR_CRITICAL = "critical"

    attr_reader :base_url

    def initialize(base_url, http_client: HTTPClient.new)
      @base_url = base_url.to_s.delete_suffix("/")
      @http_client = http_client
    end

    def status
      status_payload.fetch("indicator")
    end

    def description
      status_payload.fetch("description")
    end

    def operational?
      status == INDICATOR_NONE
    end

    def degraded?
      status == INDICATOR_MINOR
    end

    def major_outage?
      status == INDICATOR_MAJOR || status == INDICATOR_CRITICAL
    end

    def components
      @components ||= Component.build_all(http_get("components.json")["components"])
    end

    def component(name)
      components.find { |component| component.name == name }
    end

    def incidents
      @incidents ||= fetch_incidents("incidents/unresolved.json", "incidents")
    end

    private

    attr_reader :http_client

    def status_payload
      @status_payload ||= http_get("status.json").fetch("status")
    end

    def fetch_incidents(path, key)
      Incident.build_all(http_get(path)[key])
    end

    def http_get(path)
      http_client.get_json("#{base_url}/api/v2/#{path}")
    end
  end
end
