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
    expect(incident.name).to eq("Elevated error rates on API")
    expect(incident.status).to eq("investigating")
    expect(incident.impact).to eq("minor")
    expect(incident.created_at).to eq("2026-04-16T09:31:00Z")
    expect(incident.updated_at).to eq("2026-04-16T09:45:00Z")

    update_bodies = incident.updates.map(&:body)
    expect(update_bodies).to eq([
      "We are investigating elevated error rates.",
      "We identified the cause and are working on a fix."
    ])

    first_update = incident.updates.first
    expect(first_update.status).to eq("investigating")
    expect(first_update.created_at).to eq("2026-04-16T09:31:00Z")
  end
end
