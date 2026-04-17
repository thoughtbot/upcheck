# frozen_string_literal: true

RSpec.describe "Scheduled maintenances integration" do
  before { register_test_provider }

  it "returns active scheduled maintenances with the same shape as incidents" do
    stub_statuspage("scheduled-maintenances/active.json", fixture: "scheduled_active.json")

    maintenances = Upcheck.for(:test).scheduled_maintenances

    expect(maintenances.size).to eq(1)

    maintenance = maintenances.first
    expect(maintenance.name).to eq("December Scheduled Maintenance Window")
    expect(maintenance.status).to eq("in_progress")
    expect(maintenance.impact).to eq("maintenance")
    expect(maintenance.scheduled_for).to eq("2026-04-17T20:00:00.000Z")
    expect(maintenance.scheduled_until).to eq("2026-04-17T22:00:00.000Z")
    expect(maintenance.updates.map(&:status)).to eq(["in_progress", "scheduled"])
  end
end
