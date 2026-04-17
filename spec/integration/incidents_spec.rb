# frozen_string_literal: true

RSpec.describe "Incidents integration" do
  before { register_test_provider }

  it "returns an empty list when there are no unresolved incidents" do
    stub_statuspage("incidents/unresolved.json", fixture: "incidents_none.json")

    expect(Upcheck.for(:test).incidents).to eq([])
  end

  it "returns active incidents with their updates" do
    stub_statuspage("incidents/unresolved.json", fixture: "incidents_unresolved.json")

    incidents = Upcheck.for(:test).incidents

    expect(incidents.size).to eq(1)

    incident = incidents.first
    expect(incident.name).to eq("Disruption with some GitHub services")
    expect(incident.status).to eq("investigating")
    expect(incident.impact).to eq("minor")
    expect(incident.created_at).to eq("2026-04-17T14:56:22.556Z")
    expect(incident.updated_at).to eq("2026-04-17T15:08:06.465Z")
    expect(incident.resolved_at).to be_nil

    update_statuses = incident.updates.map(&:status)
    expect(update_statuses).to all(eq("investigating"))
    expect(incident.updates.first.body).to start_with("We have isolated a problematic component")
  end
end
