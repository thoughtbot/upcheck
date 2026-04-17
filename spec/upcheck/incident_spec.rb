# frozen_string_literal: true

RSpec.describe Upcheck::Incident do
  let(:payload) do
    {
      "name" => "Something is broken",
      "status" => "identified",
      "impact" => "major",
      "created_at" => "2026-04-16T09:00:00Z",
      "updated_at" => "2026-04-16T09:30:00Z",
      "resolved_at" => nil,
      "shortlink" => "https://stspg.io/xyz",
      "incident_updates" => [
        {
          "status" => "investigating",
          "body" => "Looking into it.",
          "created_at" => "2026-04-16T09:00:00Z"
        }
      ]
    }
  end

  it "exposes the top-level fields" do
    incident = described_class.new(payload)

    expect(incident.name).to eq("Something is broken")
    expect(incident.status).to eq("identified")
    expect(incident.impact).to eq("major")
    expect(incident.created_at).to eq("2026-04-16T09:00:00Z")
    expect(incident.updated_at).to eq("2026-04-16T09:30:00Z")
    expect(incident.resolved_at).to be_nil
    expect(incident.shortlink).to eq("https://stspg.io/xyz")
  end

  it "wraps each incident update in an Incident::Update" do
    incident = described_class.new(payload)

    expect(incident.updates.size).to eq(1)
    expect(incident.updates.first).to be_a(Upcheck::Incident::Update)
    expect(incident.updates.first.body).to eq("Looking into it.")
    expect(incident.updates.first.status).to eq("investigating")
  end

  it "returns an empty array when incident_updates is missing" do
    incident = described_class.new("name" => "x")

    expect(incident.updates).to eq([])
  end
end
