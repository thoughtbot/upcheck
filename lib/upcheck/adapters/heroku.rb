# frozen_string_literal: true

module Upcheck
  module Adapters
    class Heroku
      URL = "https://status.heroku.com/api/v4/current-status.json"

      COLOR_TO_STATUS = {
        "green" => "none",
        "blue" => "maintenance",
        "yellow" => "minor",
        "red" => "major"
      }.freeze

      COLOR_SEVERITY = {"green" => 0, "blue" => 1, "yellow" => 2, "red" => 3}.freeze

      STATUS_TO_DESCRIPTION = {
        "none" => "All systems operational",
        "maintenance" => "Systems under maintenance",
        "minor" => "Some systems experiencing degradation",
        "major" => "Major service disruption"
      }.freeze

      COLOR_TO_COMPONENT_STATUS = {
        "green" => "operational",
        "blue" => "under_maintenance",
        "yellow" => "degraded_performance",
        "red" => "major_outage"
      }.freeze

      def initialize(http_client: HTTPClient.new)
        @http_client = http_client
      end

      def status
        worst_color = payload.fetch("status")
          .map { |s| s["status"] }
          .max_by { |color| translate(COLOR_SEVERITY, color) }

        return "none" if worst_color.nil?

        translate(COLOR_TO_STATUS, worst_color)
      end

      def description = STATUS_TO_DESCRIPTION.fetch(status)

      def components
        @components ||= payload.fetch("status").map do |entry|
          Component.new(
            "name" => entry["system"],
            "status" => translate(COLOR_TO_COMPONENT_STATUS, entry["status"])
          )
        end
      end

      def incidents
        @incidents ||= build_incidents(payload.fetch("incidents"))
      end

      def scheduled_maintenances
        @scheduled_maintenances ||= build_incidents(payload.fetch("scheduled"))
      end

      private

      attr_reader :http_client

      def payload
        @payload ||= http_client.get_json(URL)
      end

      def translate(map, color)
        map.fetch(color) do
          raise ParseError, "Unexpected Heroku system status color: #{color.inspect}"
        end
      end

      def build_incidents(list)
        list.map do |entry|
          Incident.new(
            "id" => entry["id"],
            "name" => entry["title"],
            "status" => entry["state"],
            "created_at" => entry["created_at"],
            "updated_at" => entry["updated_at"],
            "resolved_at" => entry["resolved_at"],
            "incident_updates" => translate_updates(entry["updates"])
          )
        end
      end

      def translate_updates(updates)
        (updates || []).map do |update|
          {
            "status" => update["update_type"],
            "body" => update["contents"],
            "created_at" => update["created_at"],
            "updated_at" => update["updated_at"]
          }
        end
      end
    end
  end
end
