# frozen_string_literal: true

module Upcheck
  module Adapters
    class Statuspage
      def initialize(base_url, http_client: HTTPClient.new)
        @base_url = base_url.to_s.delete_suffix("/")
        @http_client = http_client
      end

      def status = status_payload.fetch("indicator")
      def description = status_payload.fetch("description")

      def components
        @components ||= Component.build_all(http_get("components.json")["components"])
      end

      def incidents
        @incidents ||= fetch_incidents("incidents/unresolved.json", "incidents")
      end

      def scheduled_maintenances
        @scheduled_maintenances ||= fetch_incidents("scheduled-maintenances/active.json", "scheduled_maintenances")
      end

      private

      attr_reader :base_url, :http_client

      def status_payload
        @status_payload ||= http_get("status.json").fetch("status")
      end

      def fetch_incidents(path, key) = Incident.build_all(http_get(path)[key])

      def http_get(path) = http_client.get_json("#{base_url}/api/v2/#{path}")
    end
  end
end
