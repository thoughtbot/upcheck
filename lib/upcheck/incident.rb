# frozen_string_literal: true

module Upcheck
  class Incident < Resource
    class Update < Resource
      attribute :status, :body, :created_at, :updated_at, :display_at
    end

    attribute :id, :name, :status, :impact, :shortlink,
      :created_at, :updated_at, :started_at, :resolved_at

    def updates
      @updates ||= Array(@attributes["incident_updates"]).map { |update| Update.new(update) }
    end
  end
end
