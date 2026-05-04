# frozen_string_literal: true

module Upcheck
  class Provider
    INDICATOR_NONE = "none"
    INDICATOR_MINOR = "minor"
    INDICATOR_MAJOR = "major"
    INDICATOR_CRITICAL = "critical"
    INDICATOR_MAINTENANCE = "maintenance"

    def initialize(adapter)
      @adapter = adapter
    end

    def status = adapter.status
    def description = adapter.description
    def components = adapter.components
    def incidents = adapter.incidents
    def scheduled_maintenances = adapter.scheduled_maintenances

    def operational? = status == INDICATOR_NONE
    def degraded? = status == INDICATOR_MINOR
    def major_outage? = status == INDICATOR_MAJOR || status == INDICATOR_CRITICAL
    def maintenance? = status == INDICATOR_MAINTENANCE

    def component(id: nil, name: nil)
      raise ArgumentError, "pass exactly one of id: or name:" if [id, name].compact.size != 1
      components.find { |c| (id && c.id == id) || (name && c.name == name) }
    end

    private attr_reader :adapter
  end
end
