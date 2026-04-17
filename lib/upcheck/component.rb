# frozen_string_literal: true

module Upcheck
  class Component < Resource
    STATUS_OPERATIONAL = "operational"
    STATUS_DEGRADED_PERFORMANCE = "degraded_performance"
    STATUS_PARTIAL_OUTAGE = "partial_outage"
    STATUS_MAJOR_OUTAGE = "major_outage"
    STATUS_UNDER_MAINTENANCE = "under_maintenance"

    attribute :name, :status, :description

    def operational?
      status == STATUS_OPERATIONAL
    end

    def degraded?
      status == STATUS_DEGRADED_PERFORMANCE
    end

    def partial_outage?
      status == STATUS_PARTIAL_OUTAGE
    end

    def major_outage?
      status == STATUS_MAJOR_OUTAGE
    end

    def maintenance?
      status == STATUS_UNDER_MAINTENANCE
    end
  end
end
