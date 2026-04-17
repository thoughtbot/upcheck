# frozen_string_literal: true

module Upcheck
  class Incident < Resource
    class Update < Resource
      attribute :status, :body, :created_at, :updated_at, :display_at
    end

    attribute :id, :name, :status, :impact, :shortlink,
      :created_at, :updated_at, :started_at, :resolved_at,
      :scheduled_for, :scheduled_until

    def updates
      @updates ||= Update.build_all(@attributes["incident_updates"])
    end
  end
end
